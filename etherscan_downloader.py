import csv
import os
import time
from etherscan.contracts import Contract

contract_addresses = []

with open('export-verified-contractaddress-opensource-license.csv', newline='') as csvfile:
    spamreader = csv.DictReader(csvfile, delimiter=',')
    for row in spamreader:
        contract_addresses.append(row["ContractAddress"])

# download each contract source code
def download_contract_source_code(address):
    filename = f"etherscan_dataset/{address}.sol"
    if os.path.exists(filename):
        print(f"{filename} already exists, skipping...")
        return
    print(f"downloading {address}")
    with open('etherscan_api_key.txt', mode='r') as key_file:
        key = key_file.read()

    api = Contract(address=address, api_key=key)
    sourcecode = api.get_sourcecode()
    with open(filename, "w+") as f:
        f.write(sourcecode[0]['SourceCode'])

for address in contract_addresses:
    download_contract_source_code(address)
