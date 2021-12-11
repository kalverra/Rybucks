#!/usr/bin/python3

from brownie import accounts, Contract
import sys
import json

def main():
  contract_address = ""
  ryan_address = ""
  acct = accounts.load('deployment_account')

  with open("./build/contracts/RySale.json") as abi_file:
    abi_json = json.load(abi_file)
    abi_string = abi_json["abi"]
    ry_sale = Contract.from_abi("RySale", contract_address, abi_string)
    ry_sale.sendToRyan(ryan_address, {'from': acct})
