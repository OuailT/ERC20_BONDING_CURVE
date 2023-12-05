// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;


import import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./curves/BancorFormula.sol";


contract ERC20BondingCurve is BancorFormula, ERC20 {

    // Define Important state variables
    uint public decimals = 10**18;
    
    // Set Initially the reverve balance to 100 USDT
    uint public reserveBalance = 100 * decimals;

    // set reserves address (USDT)
    address public reserveAddress;
    
    // set reserves Ratio
    uint public reserveRatio;


    event MintTokens(address indexed Minter, uint256 amountToMint);



    // constructor;
    /***
        param: reverve ration, reserve address
        define ERC20 tokens BTC and mint 10 BTC to the deployer
        Natspec: 
    */
    
    /**
     * ReserveRation = Price sensitivity
     * // NOTE: The _reserveratio will be held constant by The Bancor formula as both the 'ReverveTokenBalance' and 'TotalSupply' fluctuate with buys and sells.
       // ReserveRatio determines how sharply a Continuous Token's prices needs to adjust in order to be maintained with every transaction.
     * @param _reserveRatio(RR) to determine the bonding curve to be used. 50% RR = Linear Bonding Curve, 10% RR = Exponential Bonding Curve
     * @param _reserveTokenAddress Contract address of ERC20 Token to use as reserve/exchange of value e.g USDT
     */
    constructor(uint256 _reserveRatio, address _reserveAddress) {
        ERC20("Bonded Token", "BTC");
        reserveRatio = _reserveRatio;
        reserveAddress = _reserveAddress;
        _mint(msg.sender, 10 * decimals);
    }


    
    /**
        * @dev Mints new tokens in exchange for the deposited reserve tokens.
        *      Requires the sender to have a sufficient allowance for the contract to spend reserve tokens.
        * @param _depositedAmount The amount of reserve tokens to be deposited by the sender.
        * @return _amountMinted The amount of new tokens minted as a result of the deposit.
        * @notice Mints tokens in return for reserve tokens, subject to sender's allowance and transfer success.
    */
    function mint(uint _depositedAmount) public returns (uint _amountMinted) {
        
        require(_depositedAmount > 0, "_depositedAmount_CANNOT_BE_ZERO");

        // Check if the contract has enough allowance
        uint allowance = IERC20(reserveAddress).allowance(msg.sender, address(this));
        
        require(_depositedAmount >= allowance, "NOT_ENOUGH_ALLOWANCE");
      
        bool succ = IERC20(reserveAddress).transferFrom(msg.sender, address(this), allowance);
        require(succ, "Transfer of reserve tokens failed");

        return _continousMint(allowance); // to create later
    }


    // mint _contiounsMint
    /** 
        purpose: to calculate the deposit amount of the user and mint an equivalent BTC tokens 
        NOTE: verify the visibility is correct???????(Later)
        param: deposit check deposit is greater than 0 
        calculate minted tokens using purchaseCalculate function from Bancor.[x]
        Add the deposited amount to the USDT reserve balance; [x]
        mint tokens[x];
        fire an event [x]

    */
    function _continousMint(uint _deposit) public returns(uint256) {

        uint amountToMint = calculateContinuousMintReturn(_deposit);  // craft later
        
        reserveBalance += _deposit;

        _mint(msg.sender, amountToMint * decimals);

        emit MintTokens(msg.sender, amountToMint);

        return amountToMint;
    }



    // function calculateContinuousMintReturn() internal 
    
    



}
