"""
=============================================================================
HE THONG GOI MON TAI BAN QUA MA QR - CHOUXCHIN
Do an tot nghiep: Nguyen Huynh Anh Tuan - S26-K65CNTT
Tap lenh: generate_qr.py
Chuc nang: Tu dong hoa sinh ma QR phan giai cao cho 12 ban an trong quan
=============================================================================
"""

import os
import sys
import urllib.parse
import urllib.request

# Ho tro hien thi Unicode tren terminal Windows
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

# 1. Duong dan thu muc luu anh QR trong do an
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUTPUT_DIR = os.path.join(BASE_DIR, "anhqr")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# 2. Ten mien ung dung Web khach hang da deploy chinh thuc tren Vercel
DEPLOY_DOMAIN = "https://nguyenhuynhanhtuans26k65cntt.vercel.app"

# 3. Tong so ban theo thiet ke co so du lieu (Ban 01 -> Ban 12)
TOTAL_TABLES = 12

def generate_table_qr_codes():
    print(f"[*] Bat dau sinh ma QR cho {TOTAL_TABLES} ban...")
    print(f"[*] Ten mien trien khai: {DEPLOY_DOMAIN}")
    print(f"[*] Thu muc luu tru: {OUTPUT_DIR}\n")

    for i in range(1, TOTAL_TABLES + 1):
        table_code = f"Ban_{i:02d}"
        table_label = f"Bàn {i:02d}"

        # Cau truc URL dinh danh ban (Table Deep Link)
        target_url = f"{DEPLOY_DOMAIN}/?table={urllib.parse.quote(table_label)}"
        
        # API chuan hoa ma tran QR phan giai cao 400x400 (ISO/IEC 18004)
        encoded_url = urllib.parse.quote(target_url)
        qr_api_endpoint = f"https://api.qrserver.com/v1/create-qr-code/?size=400x400&data={encoded_url}"

        output_file_path = os.path.join(OUTPUT_DIR, f"{table_code}.png")

        try:
            urllib.request.urlretrieve(qr_api_endpoint, output_file_path)
            print(f"  [OK] Thanh cong: {table_label} -> {table_code}.png ({target_url})")
        except Exception as e:
            print(f"  [ERR] Loi khi tao ma cho {table_label}: {e}")

    print(f"\n[DONE] Hoan tat tao {TOTAL_TABLES} ma QR thanh cong!")

if __name__ == "__main__":
    generate_table_qr_codes()
