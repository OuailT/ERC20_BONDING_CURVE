// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "./curves/BancorFormula.sol";

// contract ContinousToken is BancorFormula, ERC20 {
//     using SafeMath for uint256;

//     uint256 public scale = 10**18;
//     uint256 public reserveBalance = 10 * scale;
//     uint256 public reserveRatio;
//     address public reserveTokenAddress;


//     // Stop at this function "calculateContinuousMintReturn" TODO Explore more
//     // Check if the Bancor protocol still have the same function to calculateContinuousMintReturn and other functions as well. 


//     // _continuousMint() and _continuousBurn() are internal functions that increase or decrease the total supply respectievly. 
    
//     /**
//      * @dev Fired when TOK is exchanged for Dai
//      */
//     event ContinuousBurn(
//         address _address,
//         uint256 continuousTokenAmount,
//         uint256 reserveTokenAmount
//     );


//     /**
//      * @dev Fired when Dai us exchanged for TOK
//      */
//     event ContinuousMint(
//         address _address,
//         uint256 reserveTokenAmount,
//         uint256 continuousTokenAmount
//     );



//     /**
//      * ReserveRation = Price sensitivity
//      * // NOTE: The _reserveratio will be held constant by The Bancor formula as both the 'ReverveTokenBalance' and 'TotalSupply' fluctuate with buys and sells.
//        // ReserveRatio determines how sharply a Continuous Token's prices needs to adjust in order to be maintained with every transaction.
//      * @param _reserveRatio(RR) to determine the bonding curve to be used. 50% RR = Linear Bonding Curve, 10% RR = Exponential Bonding Curve
//      * @param _reserveTokenAddress Contract address of ERC20 Token to use as reserve/exchange of value e.g DAI
//      */
//     constructor(uint256 _reserveRatio, address _reserveTokenAddress)
//         ERC20("Continous Token", "TOK")
//     {
//         reserveRatio = _reserveRatio;
//         reserveTokenAddress = _reserveTokenAddress;
//         _mint(msg.sender, 1 * scale);
//     }


//     // TOK/ETH


//     /**
//      * @dev Mint some TOK token by allowing contract to spend an amount of caller reserve tokens(Token to pay with to get TOK token)
//      * @param _amount Number of reserve token approved for this contract to convert to TOK tokens
//      */
//     function mint(uint256 _amount) public returns (uint256 _amountMinted) {
//         // Verifying if the the user gives approval to the address(this) to spend "reserveTokenAddress" token on my behalf.
//         uint256 allowance = IERC20(reserveTokenAddress).allowance(
//             msg.sender,
//             address(this)
//         );

//         require(allowance > 0, "Must approve DAI to buy tokens.");
//         require(allowance >= _amount, "Must approve enough DAI.");

//         bool success = IERC20(reserveTokenAddress).transferFrom(
//             msg.sender,
//             address(this),
//             allowance
//         );

//         if (success) {
//             return  _continuousMint(allowance);
//         } else {
//             require(allowance > 0, "Failed to transfer Dai tokens");
//         }
//     }


//     // PurchaseReturn = ContinuousTokenSupply * ((1 + ReserveTokensReceived / ReserveTokenBalance) ^ (ReserveRatio) - 1)
//     // SaleReturn = ReserveTokenBalance * (1 - (1 - ContinuousTokensReceived / ContinuousTokenSupply) ^ (1 / (ReserveRatio)))

//     /**@notice purchaseTargetAmount returns a price for a given buy token amount.
//      * @dev Burn some TOK token and return reserve token based on current curve price
//      * @param _amount Number of TOK token to convert to reserve tokens
//      */
//     function burn(uint256 _amount) public {
//         uint256 returnAmount = _continuousBurn(_amount);
//         IERC20(reserveTokenAddress).transfer(msg.sender, returnAmount);
//     }


//     /**
//      * @notice calculates the target amount of the main token(BTC) for a given conversion(eg, ETH, USDT, etc);
//     */
//     function calculateContinuousMintReturn(uint256 _amount)
//         public
//         view
//         returns (uint256 mintAmount)
//     {
//         return purchaseTargetAmount(
//                 totalSupply(),
//                 reserveBalance,
//                 uint32(reserveRatio),
//                 _amount
//             );
//     }


    
//     function calculateContinuousBurnReturn(uint256 _amount)
//         public
//         view
//         returns (uint256 burnAmount)
//     {
//         return
//             saleTargetAmount(
//                 totalSupply(),
//                 reserveBalance,
//                 uint32(reserveRatio),
//                 _amount
//             );
//     }



//     /**
//      * @dev Internal function to increases the total supply by minting the specified amount of tokens based on the deposited token(e.g, ETH);
//      * @param _amount Amount of tokens to be minted
//      */
//     function _continuousMint (uint256 _deposit) internal returns (uint256) {
//         require(_deposit > 0, "Deposit must be non-zero.");

//         uint256 amount = calculateContinuousMintReturn(_deposit);

//         _mint(msg.sender, amount);

//         reserveBalance = reserveBalance.add(_deposit);
//         emit ContinuousMint(msg.sender, _deposit, amount);
//         return amount;
//     }


//     function _continuousBurn(uint256 _amount) internal returns (uint256) {
//         require(_amount > 0, "Amount must be non-zero.");
//         require(
//             balanceOf(msg.sender) >= _amount,
//             "Insufficient tokens to burn."
//         );

//         uint256 reimburseAmount = calculateContinuousBurnReturn(_amount);
//         _burn(msg.sender, _amount);
//         reserveBalance = reserveBalance.sub(reimburseAmount);
//         emit ContinuousBurn(msg.sender, _amount, reimburseAmount);
//         return reimburseAmount;
//     }
// }
