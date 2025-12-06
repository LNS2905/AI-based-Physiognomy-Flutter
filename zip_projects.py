import shutil
import os
import zipfile

def zip_dir(src_dir, zip_name, exclude_dirs=None):
    if exclude_dirs is None:
        exclude_dirs = []
        
    print(f"Zipping {src_dir} to {zip_name}...")
    
    with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(src_dir):
            # Filter out excluded directories
            dirs[:] = [d for d in dirs if d not in exclude_dirs]
            
            for file in files:
                if file == zip_name: continue
                
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, src_dir)
                zf.write(file_path, arcname)
                
    print(f"Created {zip_name}")

# 1. Zip ai-physio-be
zip_dir(r"C:\Code\ai-physio-be", "ai-physio-be.zip", exclude_dirs=["node_modules", ".git", "dist"])

# 2. Zip lasotuvi-private
zip_dir(r"C:\Code\lasotuvi-private", "lasotuvi.zip", exclude_dirs=["__pycache__", ".git", "venv", "env"])
