import os
import sys
import requests
import json
import uuid


url = "https://192.168.4.208:8834"
username = "nessus"
scan_name = "name7"
target = "192.168.42.3"


def get_nessus_token(url, username, scan_name, target):
    scan_found = False
    url_token = f"{url}/session"
    data = {"username": "nessus", "password": "technet24"}
    #print(data)
    response = requests.post(url_token, json=data, verify=False)
    token = json.loads(response.text)["token"]
    print(token)
    url_scan = f"{url}/scans"
    #print(url_scan)
    headers = {"X-Cookie": f"token={token}"}
    print(headers)
    response_scan = requests.get(url_scan, headers=headers, verify=False)
    scans = response_scan.json()["scans"]

    for scan in scans:
        if scan["name"] == scan_name:
            scan_id = scan["id"]
            url_launch = f"https://192.168.4.208:8834/scans/{scan_id}/launch"
            response = requests.post(url_launch, headers=headers, verify=False)
            if response.status_code == 200:

                print("Lunch scan by id: status code",response.status_code)
                return response.json()
            else:
                print(f"Error: Scan lunch failed!, {response.json()}")
                sys.exit(1)
            scan_found = True
            break

    if not scan_found:
             print("Start Create New Scan ")
             url_create = "https://192.168.4.208:8834/scans"
             headers_create = {
                 "X-Cookie": f"token={token}",
                 "Content-Type": "application/json"
                 }
             payload = {
                 "uuid": "ab4bacd2-05f6-425c-9d79-3ba3940ad1c24e51e1f403febe40",
                 "settings": {
                     "name": scan_name,
                     "text_targets": target,
                     "policy_id": 61,
                     "launch": "ON_DEMAND"
                     }
                 }
             print(payload)
             response_create = requests.post(url_create, headers=headers_create,json=payload ,verify=False)
             print(response_create.json())
get_nessus_token(url, username, scan_name, target)
