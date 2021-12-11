#!/usr/bin/python3

import pytest


@pytest.fixture(scope="function", autouse=True)
def isolate(fn_isolation):
    # perform a chain rewind after completing each test, to ensure proper isolation
    # https://eth-brownie.readthedocs.io/en/v1.10.3/tests-pytest-intro.html#isolation-fixtures
    pass


@pytest.fixture(scope="module")
def token(RyBucks, accounts):
    return RyBucks.deploy({'from': accounts[0]})

@pytest.fixture(scope="function", autouse=True)
def ry_sale_setup(RyBucks, accounts, RySale):
    token = RyBucks.deploy({'from': accounts[0]})
    total_supply = token.totalSupply()
    exchange_rate = 462_819_404
    ry_sale = RySale.deploy(exchange_rate, accounts[0], token.address, {'from': accounts[0]})
    token.transfer(ry_sale.address, total_supply)
    assert token.balanceOf(ry_sale.address) == total_supply
    return token, ry_sale
    