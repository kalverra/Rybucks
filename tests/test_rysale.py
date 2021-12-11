#!/usr/bin/python3
import pytest
import brownie

ry_bucks_mult = 10 ** 18
ry_bucks_total = 69_000_000_000_000
wei_for_ten_mil_ry_bucks = 21_606_700_000_000_000

def test_purchase(accounts, ry_sale_setup):
  token = ry_sale_setup[0]
  ry_sale = ry_sale_setup[1]
  
  address_initial_eth_balance = accounts[0].balance()
  ry_sale_initial_balance = token.balanceOf(ry_sale.address)

  accounts[2].transfer(ry_sale.address, wei_for_ten_mil_ry_bucks)
  print(token.balanceOf(accounts[2]))
  assert accounts[0].balance() > address_initial_eth_balance
  assert accounts[0].balance() == address_initial_eth_balance + wei_for_ten_mil_ry_bucks
  assert token.balanceOf(accounts[2]) > 0
  assert token.balanceOf(ry_sale.address) < ry_sale_initial_balance
  
  # With the RyBucks... unique exchange rate, math gets weird
  assert token.balanceOf(accounts[2]) > 10_000_000 * ry_bucks_mult
  assert token.balanceOf(accounts[2]) < 10_000_001 * ry_bucks_mult
