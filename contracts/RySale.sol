// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RySale
 * @dev RySale is a modified and updated version of the open zeppelin Crowdsale contract, used for RyBucks
 */
contract RySale is Ownable {
  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address payable public wallet;

  // How many token units a buyer gets per wei
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * Event for the eventual transfer of 10 million RyBucks to the original Ryan
   * @param Rydress address of the actual Ryan to send to
   * @param amount amount of tokens sent
   */
  event RyFer(
    address indexed Rydress,
    uint256 amount
  );

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor(uint256 _rate, address payable _wallet, ERC20 _token) {
    require(_rate > 0);
    require(_wallet != address(0));
    require(address(_token) != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // RySale external interface
  // -----------------------------------------

  /**
   * @dev receive function ***DO NOT OVERRIDE***
   */
  receive() external payable {
    uint256 weiAmount = msg.value;
    _preValidatePurchase(msg.sender, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);
    _validateTokenAmounts(tokens);

    // update state
    weiRaised = weiRaised + weiAmount;

    _processPurchase(msg.sender, tokens);
    emit TokenPurchase(
      msg.sender,
      msg.sender,
      weiAmount,
      tokens
    );

    _updatePurchasingState(msg.sender, weiAmount);

    _forwardFunds();
    _postValidatePurchase(msg.sender, weiAmount);
  }

  /**
  * @dev Enables sending coins to the original and almighty Ryan. Praise be unto his name.
  * This will send 10 million RyBucks to Ryan's address, whenever he provides it to me.
  */
  function sendToRyan(address _beneficiary) external onlyOwner {
    _validateTokenAmounts(10_000_000_000_000_000_000_000_000);
    _deliverTokens(_beneficiary, 10_000_000_000_000_000_000_000_000);
    emit RyFer(_beneficiary, 10_000_000_000_000_000_000_000_000);
  }

  /**
   * @dev Enables buying tokens with a promo code
   * @param _beneficiary Address performing the token purchase
   * @param _promo Promo code
   */
  function buyTokensPromo(address _beneficiary, string calldata _promo) external payable {
    require(keccak256(abi.encodePacked(_promo)) == keccak256(abi.encodePacked("#BANANAPENIS")), "Invalid promo code");
    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount) + 10_000_000; // Add 10_000_000 for correct promo code
    _validateTokenAmounts(tokens);

    // update state
    weiRaised = weiRaised + weiAmount;

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  function _validateTokenAmounts(uint256 _tokensAmount) internal {
    require(token.balanceOf(address(this)) > _tokensAmount, "Not enough tokens");
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.transfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount * rate;
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}