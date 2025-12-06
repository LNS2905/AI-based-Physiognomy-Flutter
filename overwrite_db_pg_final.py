import paramiko
import sys
import time

# Force UTF-8 output
sys.stdout.reconfigure(encoding='utf-8')

hostname = "160.250.180.132"
username = "root"
password = "Do@nhkiet262205"

def execute_command(ssh, command):
    print(f"\n[REMOTE] Executing: {command}")
    stdin, stdout, stderr = ssh.exec_command(command)
    exit_status = stdout.channel.recv_exit_status()
    output = stdout.read().decode('utf-8', errors='replace').strip()
    error = stderr.read().decode('utf-8', errors='replace').strip()
    if output: print(f"STDOUT:\n{output}")
    if error: print(f"STDERR:\n{error}")
    return output

try:
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, username=username, password=password)
    
    # The error persists: ArgumentError ... string '"..."'
    # This means the value "..." (with quotes) is STILL being used.
    # Even after sed patching and rebuilding.
    
    # Possibility 1: I patched the WRONG file.
    # Possibility 2: The volume mount? (No volumes in docker run command)
    # Possibility 3: The file path in container is NOT what I think.
    # The logs say: File "/app/lasotuvi/api/database_pg.py"
    # My Dockerfile COPY . . puts everything in /app.
    # So /root/lasotuvi/lasotuvi/api/database_pg.py -> /app/lasotuvi/api/database_pg.py. This seems correct.
    
    # Let's check the file content ON DISK again to be absolutely sure.
    print("\n--- CHECKING FILE CONTENT ON DISK ---")
    execute_command(client, "cat /root/lasotuvi/lasotuvi/api/database_pg.py | grep DATABASE_URL")
    
    # Let's try to remove the file and recreate it with Python content DIRECTLY.
    # And verify the output.
    
    db_url = "postgresql://physio_db:290503Sang.@160.250.180.132:2905/physio_db"
    
    # Escape braces for f-string
    overwrite_py_script = f"""
    cat > /root/lasotuvi/lasotuvi/api/database_pg.py <<EOF
\"\"\"PostgreSQL database adapter for lasotuvi (replacing SQLite)\"\"\"

from sqlalchemy import create_engine, Column, Integer, JSON, DateTime, Index, String, Boolean, Text, Float, ForeignKey, Enum
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from datetime import datetime
from typing import Dict, List, Any, Optional
import os
import enum

# Hardcoded for stability
DATABASE_URL = "{db_url}"

# Create engine
engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class MessageRoleEnum(enum.Enum):
    user = "user"
    assistant = "assistant"
    system = "system"

class MessageTypeEnum(enum.Enum):
    initial_analysis = "initial_analysis"
    question = "question"
    daily_fortune = "daily_fortune"
    clarification_request = "clarification_request"
    tool_result = "tool_result"

class GenderEnum(enum.Enum):
    male = "male"
    female = "female"

class TuviChart(Base):
    __tablename__ = "TuviChart"
    id = Column(Integer, primary_key=True, index=True)
    userId = Column(Integer, nullable=False, index=True)
    payload = Column(JSON, nullable=False)
    houses = Column(JSON, nullable=False)
    extra = Column(JSON, nullable=False)
    createdAt = Column(DateTime, nullable=False, default=datetime.utcnow)
    updatedAt = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
    ownerName = Column(String)
    birthDate = Column(DateTime)
    birthHour = Column(Integer)
    gender = Column(Enum(GenderEnum))
    solarBirthDate = Column(DateTime)
    lunarBirthDate = Column(String)
    birthPlace = Column(String)
    timezone = Column(String)
    isPrimary = Column(Boolean, default=False, index=True)
    delFlag = Column(Boolean, default=False, index=True)
    conversations = relationship("TuviConversation", back_populates="chart", cascade="all, delete-orphan")
    __table_args__ = (
        Index('idx_tuvichart_userid', 'userId'),
        Index('idx_tuvichart_created', 'createdAt'),
        Index('idx_tuvichart_userid_primary', 'userId', 'isPrimary'),
        Index('idx_tuvichart_userid_delflag', 'userId', 'delFlag'),
    )

class TuviConversation(Base):
    __tablename__ = "TuviConversation"
    id = Column(Integer, primary_key=True, index=True)
    userId = Column(Integer, nullable=False, index=True)
    chartId = Column(Integer, ForeignKey("TuviChart.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String)
    agentState = Column(JSON)
    hasInitialAnalysis = Column(Boolean, default=False)
    createAt = Column(DateTime, default=datetime.utcnow, index=True)
    updateAt = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, index=True)
    delFlag = Column(Boolean, default=False, index=True)
    chart = relationship("TuviChart", back_populates="conversations")
    messages = relationship("TuviMessage", back_populates="conversation", cascade="all, delete-orphan", order_by="TuviMessage.createAt")
    __table_args__ = (
        Index('idx_tuviconv_userid_delflag', 'userId', 'delFlag'),
        Index('idx_tuviconv_chartid', 'chartId'),
        Index('idx_tuviconv_updateat', 'updateAt'),
    )

class TuviMessage(Base):
    __tablename__ = "TuviMessage"
    id = Column(Integer, primary_key=True, index=True)
    conversationId = Column(Integer, ForeignKey("TuviConversation.id", ondelete="CASCADE"), nullable=False, index=True)
    role = Column(Enum(MessageRoleEnum), nullable=False)
    content = Column(Text, nullable=False)
    messageType = Column(Enum(MessageTypeEnum))
    toolCalls = Column(JSON)
    contextDate = Column(DateTime)
    sources = Column(JSON)
    processingTime = Column(Float)
    createAt = Column(DateTime, default=datetime.utcnow, index=True)
    conversation = relationship("TuviConversation", back_populates="messages")
    __table_args__ = (
        Index('idx_tuvimsg_convid_created', 'conversationId', 'createAt'),
    )

def get_db() -> Session:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db() -> None:
    Base.metadata.create_all(bind=engine)

def insert_chart(payload: Dict[str, Any], houses: List[Dict[str, Any]], extra: Dict[str, Any], user_id: int = 1) -> int:
    db = SessionLocal()
    try:
        chart = TuviChart(userId=user_id, payload=payload, houses=houses, extra=extra)
        db.add(chart)
        db.commit()
        db.refresh(chart)
        return chart.id
    finally:
        db.close()

def fetch_chart(chart_id: int) -> Optional[Dict[str, Any]]:
    db = SessionLocal()
    try:
        chart = db.query(TuviChart).filter(TuviChart.id == chart_id).first()
        if not chart: return None
        return {{
            "id": chart.id,
            "user_id": chart.userId,
            "payload": chart.payload,
            "houses": chart.houses,
            "extra": chart.extra,
            "created_at": chart.createdAt.isoformat(),
            "updated_at": chart.updatedAt.isoformat(),
        }}
    finally:
        db.close()

def list_charts(user_id: Optional[int] = None, limit: int = 20) -> List[Dict[str, Any]]:
    db = SessionLocal()
    try:
        query = db.query(TuviChart)
        if user_id is not None: query = query.filter(TuviChart.userId == user_id)
        charts = query.order_by(TuviChart.id.desc()).limit(limit).all()
        result = []
        for chart in charts:
            result.append({{
                "id": chart.id,
                "user_id": chart.userId,
                "payload": chart.payload,
                "houses": chart.houses,
                "extra": chart.extra,
                "created_at": chart.createdAt.isoformat(),
                "updated_at": chart.updatedAt.isoformat(),
            }})
        return result
    finally:
        db.close()

def delete_chart(chart_id: int) -> bool:
    db = SessionLocal()
    try:
        chart = db.query(TuviChart).filter(TuviChart.id == chart_id).first()
        if not chart: return False
        db.delete(chart)
        db.commit()
        return True
    finally:
        db.close()
EOF
    """
    execute_command(client, overwrite_py_script)
    
    print("\n--- VERIFYING OVERWRITE ---")
    execute_command(client, "grep 'DATABASE_URL =' /root/lasotuvi/lasotuvi/api/database_pg.py")
    
    print("\n--- REBUILDING (AGAIN NO CACHE) ---")
    # Note: Using --no-cache is crucial as file changed again
    execute_command(client, "cd /root/lasotuvi && docker build --no-cache -t lasotuvi-api . && docker restart lasotuvi")
    
    print("\n--- CHECKING LOGS ---")
    time.sleep(5)
    execute_command(client, "docker logs lasotuvi --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
