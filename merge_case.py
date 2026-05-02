import os
import shutil

def merge_dirs(src, dst):
    if not os.path.exists(dst):
        os.makedirs(dst)
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        
        # Check if a case-insensitive match exists in dst
        found_d = d
        if os.path.isdir(dst):
            for d_item in os.listdir(dst):
                if d_item.lower() == item.lower():
                    found_d = os.path.join(dst, d_item)
                    break
        
        if os.path.isdir(s):
            merge_dirs(s, found_d)
        else:
            if os.path.exists(found_d):
                print(f"Conflict: {s} and {found_d} - Overwriting with {s}")
                os.remove(found_d)
            shutil.move(s, found_d)

if os.path.exists("Data") and os.path.exists("data"):
    print("Merging Data into data...")
    merge_dirs("Data", "data")
    shutil.rmtree("Data")

if os.path.exists(".dmm_backup/Data") and os.path.exists(".dmm_backup/data"):
    print("Merging .dmm_backup/Data into .dmm_backup/data...")
    merge_dirs(".dmm_backup/Data", ".dmm_backup/data")
    shutil.rmtree(".dmm_backup/Data")
