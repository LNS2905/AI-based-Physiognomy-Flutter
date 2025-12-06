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
    
    # DB URL: postgresql://physio_db:290503Sang.@160.250.180.132:2905/physio_db
    # We need to use internal IP or public IP.
    # Since we are running on the SAME server (160.250.180.132), using the public IP is fine IF firewall allows loopback.
    # But safer is to use the container name if they are on the same network, OR host gateway.
    # DB Container Name: postgres_db
    # We are not using a custom network, so they are on default bridge.
    # They can communicate via host IP (172.17.0.1 usually) mapped to host port.
    # But the user provided public IP. Let's stick to public IP but HARDCODE it in python file.
    
    # Warning: The password has a dot at the end "290503Sang." which might be tricky in regex/sed if not escaped properly.
    # Wait, the previous failure was ArgumentError: Could not parse ... string '"..."'
    # It still sees QUOTES.
    # The regex replace I added: .replace(""", "").replace("'", "") might have been messed up by python string escaping in my script.
    # Let's just replace the entire line with the hardcoded string.
    
    db_url = "postgresql://physio_db:290503Sang.@160.250.180.132:2905/physio_db"
    
    print("\n--- HARDCODING DB URL IN PYTHON ---")
    
    # Replace the entire line starting with DATABASE_URL =
    # We use a temp file approach to be safe
    
    overwrite_script = f"""
    FILE="/root/lasotuvi/lasotuvi/api/database_pg.py"
    # Create backup
    cp $FILE $FILE.bak
    
    # Replace the line. Note: We need to be careful with the dot in password.
    # Use python to write the file content to avoid sed escaping hell
    
    cat > $FILE <<EOF
\"\"\"PostgreSQL database adapter for lasotuvi (replacing SQLite)\"\"\"

from sqlalchemy import create_engine, Column, Integer, JSON, DateTime, Index, String, Boolean, Text, Float, ForeignKey, Enum
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from datetime import datetime
from typing import Dict, List, Any, Optional
import os
import enum
from dotenv import load_dotenv

load_dotenv()

# Hardcoded for stability
DATABASE_URL = "{db_url}"

# Create engine
engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# ============================================
# ENUMS for Tuvi Chat System
# ============================================

class MessageRoleEnum(enum.Enum):
    \"\"\"Message role in conversation\"\"\"
    user = "user"
    assistant = "assistant"
    system = "system"

class MessageTypeEnum(enum.Enum):
    \"\"\"Type of message for agent logic\"\"\"
    initial_analysis = "initial_analysis"
    question = "question"
    daily_fortune = "daily_fortune"
    clarification_request = "clarification_request"
    tool_result = "tool_result"

class GenderEnum(enum.Enum):
    \"\"\"Gender enum\"\"\"
    male = "male"
    female = "female"


class TuviChart(Base):
    \"\"\"
    ORM Model matching Prisma schema.
    Table name must match Prisma: TuviChart (PascalCase)
    \"\"\"
    __tablename__ = "TuviChart"
    
    id = Column(Integer, primary_key=True, index=True)
    userId = Column(Integer, nullable=False, index=True)
    payload = Column(JSON, nullable=False)
    houses = Column(JSON, nullable=False)
    extra = Column(JSON, nullable=False)
    createdAt = Column(DateTime, nullable=False, default=datetime.utcnow)
    updatedAt = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # NEW: Tuvi Chat System fields
    ownerName = Column(String)  # "Bản thân", "Con trai", "Vợ"...
    birthDate = Column(DateTime)  # Dương lịch đầy đủ
    birthHour = Column(Integer)  # 1-12 (Chi giờ)
    gender = Column(Enum(GenderEnum))
    solarBirthDate = Column(DateTime)  # Dương lịch
    lunarBirthDate = Column(String)  # Âm lịch (nếu có)
    birthPlace = Column(String)  # Nơi sinh
    timezone = Column(String)  # Múi giờ
    isPrimary = Column(Boolean, default=False, index=True)  # Lá số chính
    delFlag = Column(Boolean, default=False, index=True)
    
    # Relationships
    conversations = relationship("TuviConversation", back_populates="chart", cascade="all, delete-orphan")
    
    # Indexes
    __table_args__ = (
        Index('idx_tuvichart_userid', 'userId'),
        Index('idx_tuvichart_created', 'createdAt'),
        Index('idx_tuvichart_userid_primary', 'userId', 'isPrimary'),
        Index('idx_tuvichart_userid_delflag', 'userId', 'delFlag'),
    )


class TuviConversation(Base):
    \"\"\"
    Cuộc hội thoại về lá số Tử Vi
    Maintains conversation context and agent state
    \"\"\"
    __tablename__ = "TuviConversation"
    
    id = Column(Integer, primary_key=True, index=True)
    userId = Column(Integer, nullable=False, index=True)
    chartId = Column(Integer, ForeignKey("TuviChart.id", ondelete="CASCADE"), nullable=False, index=True)
    
    title = Column(String)  # "Sự nghiệp 2025", "Tình duyên"...
    
    # Agent State - Trạng thái conversation
    agentState = Column(JSON)  # {{
                               #   "missingInfo": ["birthPlace"],
                               #   "collectedInfo": {{"birthPlace": "Hanoi"}},
                               #   "currentStep": "collecting_info"
                               # }}
    
    hasInitialAnalysis = Column(Boolean, default=False)
    
    createAt = Column(DateTime, default=datetime.utcnow, index=True)
    updateAt = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, index=True)
    delFlag = Column(Boolean, default=False, index=True)
    
    # Relationships
    chart = relationship("TuviChart", back_populates="conversations")
    messages = relationship("TuviMessage", back_populates="conversation", cascade="all, delete-orphan", order_by="TuviMessage.createAt")
    
    # Indexes
    __table_args__ = (
        Index('idx_tuviconv_userid_delflag', 'userId', 'delFlag'),
        Index('idx_tuviconv_chartid', 'chartId'),
        Index('idx_tuviconv_updateat', 'updateAt'),
    )


class TuviMessage(Base):
    \"\"\"
    Tin nhắn trong cuộc hội thoại
    Stores user questions and AI responses with metadata
    \"\"\"
    __tablename__ = "TuviMessage"
    
    id = Column(Integer, primary_key=True, index=True)
    conversationId = Column(Integer, ForeignKey("TuviConversation.id", ondelete="CASCADE"), nullable=False, index=True)
    
    role = Column(Enum(MessageRoleEnum), nullable=False)
    content = Column(Text, nullable=False)
    
    # Agent metadata
    messageType = Column(Enum(MessageTypeEnum))
    toolCalls = Column(JSON)  # [{{"tool": "chinese_daily", "params": {{...}}, "result": {{...}}}}]
    contextDate = Column(DateTime)  # For daily fortune queries
    
    # Sources (RAG + API)
    sources = Column(JSON)  # {{"books": [...], "chineseAPI": {{...}}}}
    
    processingTime = Column(Float)  # milliseconds
    
    createAt = Column(DateTime, default=datetime.utcnow, index=True)
    
    # Relationships
    conversation = relationship("TuviConversation", back_populates="messages")
    
    # Indexes
    __table_args__ = (
        Index('idx_tuvimsg_convid_created', 'conversationId', 'createAt'),
    )


def get_db() -> Session:
    \"\"\"Get database session (for FastAPI dependency injection)\"\"\"
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db() -> None:
    \"\"\"
    Initialize database tables.
    Note: This should NOT be used in production with Prisma.
    Prisma migrations handle table creation.
    This is only for dev/testing without Prisma.
    \"\"\"
    # Create tables if they don't exist
    Base.metadata.create_all(bind=engine)


def insert_chart(
    payload: Dict[str, Any],
    houses: List[Dict[str, Any]],
    extra: Dict[str, Any],
    user_id: int = 1
) -> int:
    \"\"\"
    Insert a new Tuvi chart into database.
    
    Args:
        payload: Request data (day, month, year, etc.)
        houses: List of 12 houses with stars
        extra: Extra info (mệnh chủ, thân chủ, etc.)
        user_id: User ID (foreign key to user table)
    
    Returns:
        ID of inserted chart
    \"\"\"
    db = SessionLocal()
    try:
        chart = TuviChart(
            userId=user_id,
            payload=payload,
            houses=houses,
            extra=extra,
        )
        db.add(chart)
        db.commit()
        db.refresh(chart)
        return chart.id
    finally:
        db.close()


def fetch_chart(chart_id: int) -> Optional[Dict[str, Any]]:
    \"\"\"
    Fetch a chart by ID.
    
    Args:
        chart_id: Chart ID
    
    Returns:
        Dict with chart data or None if not found
    \"\"\"
    db = SessionLocal()
    try:
        chart = db.query(TuviChart).filter(TuviChart.id == chart_id).first()
        if not chart:
            return None
        
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
    \"\"\"
    List charts, optionally filtered by user_id.
    
    Args:
        user_id: Filter by user ID (optional)
        limit: Max number of results
    
    Returns:
        List of charts
    \"\"\"
    db = SessionLocal()
    try:
        query = db.query(TuviChart)
        
        if user_id is not None:
            query = query.filter(TuviChart.userId == user_id)
        
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
    \"\"\"
    Delete a chart by ID.
    
    Args:
        chart_id: Chart ID
    
    Returns:
        True if deleted, False if not found
    \"\"\"
    db = SessionLocal()
    try:
        chart = db.query(TuviChart).filter(TuviChart.id == chart_id).first()
        if not chart:
            return False
        
        db.delete(chart)
        db.commit()
        return True
    finally:
        db.close()
EOF
    """
    execute_command(client, overwrite_script)
    
    print("\n--- REBUILDING LASOTUVI ---")
    execute_command(client, "cd /root/lasotuvi && docker build -t lasotuvi-api . && docker restart lasotuvi")
    
    print("\n--- CHECKING LOGS ---")
    execute_command(client, "sleep 5 && docker logs lasotuvi --tail 20")
    
    client.close()

except Exception as e:
    print(f"An error occurred: {e}")
