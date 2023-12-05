// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./curves/BancorFormula.sol";


contract ERC20BondingCurve is BancorFormula, ERC20 {

    // Define Important state variables
    uint public scale = 10**18;
    
    // Set Initially the reverve balance to 100 USDT
    uint public reserveBalance = 100 * scale;

    // set reserves address (USDT)
    address public reserveTokenAddress;
    
    // set reserves Ratio
    uint public reserveRatio;


    event MintTokens(address indexed Minter, uint256 amountToMint);
    event BurnedTokens(address indexed Burner, uint256 _amountToBurn, uint256 payBackAmount);


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
    constructor(uint256 _reserveRatio, address _reserveTokenAddress) ERC20("Bonded Token", "BTC") {
        reserveRatio = _reserveRatio;
        reserveTokenAddress = _reserveTokenAddress;
        _mint(msg.sender, 10 * scale);
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
        uint allowance = IERC20(reserveTokenAddress).allowance(msg.sender, address(this));
        
        require(_depositedAmount >= allowance, "NOT_ENOUGH_ALLOWANCE");
      
        bool succ = IERC20(reserveTokenAddress).transferFrom(msg.sender, address(this), allowance);
        require(succ, "Transfer of reserve tokens failed");

        return _continousMint(allowance); // to create later
    }


    // Function burn 
    /** It purpose: allows user to sell/burn BTC token and get the reserve token price based on the curve price [x]
        param: Amount of token to withdraw/burn get back USDT [x]
        calculate the saleReturn based on the current position of the curve. [x]
        Transfer USDT to the seller [x]
     */
    function burn(uint _amount) public {
        require(_amount > 0, "amount cannot be zero");
        require(balanceOf(msg.sender) > _amount, "Not Enough Tokens");
        uint returnedAmount = _continousBurn(_amount);
        IERC20(reserveTokenAddress).transfer(msg.sender, returnedAmount);
    }


    //1. calculate the saleReturn amount based on the current position of the curve. and burn it

    function _continousBurn(uint _amount) public returns(uint256) {
        
        uint payBackAmount  = calculateContinuousBurnReturn(_amount);

        _burn(msg.sender, _amount); // Maybe An error will come from this 

        // burn(msg.sender, _amount * scale);

        reserveBalance -= payBackAmount;

        emit BurnedTokens(msg.sender, _amount, payBackAmount);

        return payBackAmount;
    }




    function _continousMint(uint _deposit) internal returns(uint256) {

        uint amountToMint = calculateContinuousMintReturn(_deposit);  // craft later
        
        reserveBalance += _deposit;

        _mint(msg.sender, amountToMint * scale);

        emit MintTokens(msg.sender, amountToMint);

        return amountToMint;
    }



    // function calculateContinuousMintReturn() internal
    /**
        purpose: Allows to calculate the price of the minted tokens based on the reservebalance(), and totalSupply() 
    */
    function calculateContinuousMintReturn(uint _amount) 
        internal
        view 
        returns(uint256 mintAmount) {
        return purchaseTargetAmount(
            totalSupply(),
            reserveBalance,
            uint32(reserveRatio),
            _amount
        );
    }


    // function  allow to calculate the amount of tokens to be withdrawn from the reserve based the amount of burned amount of BTC tokens
    function calculateContinuousBurnReturn(uint _amount) 
        internal
        view 
        returns(uint256) {
        return saleTargetAmount(
            totalSupply(),
            reserveBalance,
            uint32(reserveRatio),
            _amount
        );
    }
    

    
     




}
