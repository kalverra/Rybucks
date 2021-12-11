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
  initial_account_balance = accounts[2].balance()

  accounts[2].transfer(ry_sale.address, wei_for_ten_mil_ry_bucks)
  

  assert accounts[0].balance() > address_initial_eth_balance
  assert accounts[0].balance() == address_initial_eth_balance + wei_for_ten_mil_ry_bucks
  assert accounts[2].balance() < initial_account_balance
  assert token.balanceOf(accounts[2]) > 0
  assert token.balanceOf(ry_sale.address) < ry_sale_initial_balance
  
  # With the RyBucks'... unique exchange rate, the math gets inexact
  assert token.balanceOf(accounts[2]) > 10_000_000 * ry_bucks_mult
  assert token.balanceOf(accounts[2]) < 10_000_001 * ry_bucks_mult

def test_correct_promo(accounts, ry_sale_setup):
  token = ry_sale_setup[0]
  ry_sale = ry_sale_setup[1]

  # If anyone actually bothers to look into this enough to discover the promo code
  promo_code = "#BANANAPENIS"
  accounts[2].transfer(ry_sale.address, wei_for_ten_mil_ry_bucks)
  ten_mil_ry_bucks = token.balanceOf(accounts[2].address)

  ry_sale.buyTokensPromo(accounts[3].address, promo_code, {'value': wei_for_ten_mil_ry_bucks})

  assert token.balanceOf(accounts[3].address) > ten_mil_ry_bucks

def test_send_to_ryan(accounts, ry_sale_setup):
  token = ry_sale_setup[0]
  ry_sale = ry_sale_setup[1]

  assert token.balanceOf(accounts[3]) == 0
  ry_sale.sendToRyan(accounts[3])
  assert token.balanceOf(accounts[3]) == 10_000_000 * ry_bucks_mult