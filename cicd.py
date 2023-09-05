import hashlib
import sys
import shutil


def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


if __name__ == "__main__":
    
    src_path = sys.argv[1]

    md5 = md5(src_path)
    shutil.copy(src_path, "./release/{}.pdf".format(md5))
