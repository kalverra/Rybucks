#!/usr/bin/python3

from brownie import RyBucks, RySale, accounts


def main():
    acct = accounts.load('deployment_account')
    exchange_rate = 462_819_404
    token = RyBucks.deploy({'from': acct})
    total_supply = token.totalSupply()
    ry_sale = RySale.deploy(exchange_rate, acct, token.address, {'from': acct})
    token.transfer(ry_sale.address, total_supply)
    return token, ry_sale
