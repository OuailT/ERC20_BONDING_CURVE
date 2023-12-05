
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../ERC20BondingCurve.sol";


contract TestBondedToken is Test {

    // Import the contracts to test and Intiate it [x]
    // Create a ERC20 USDT token contracts [x]
    // Create 2 users [x]
    // Label them. [x]
    // Send USDT to each users [x]
    // 

    ERC20BondingCurve ERCBondingCurveContract;
    USDT USDTTokenContract;
    address public User1;
    address public User2;

    uint256 public reserveRatio = 500000; // 50% RR = Linear Bonding Curve.


    function setUp() public {
        USDTTokenContract = new USDT();

        ERCBondingCurveContract = new ERC20BondingCurve(
            reserveRatio,
            address(USDTTokenContract)
        );

        User1 = vm.addr(0x1234);
        User2 = vm.addr(0x5678);

        vm.label(User1, "USER1");
        vm.label(User2, "USER2");

        USDTTokenContract.transfer(User1, 50 ether);
        USDTTokenContract.transfer(User2, 50 ether);
    }

    
    function testMintingTokensSuccessfully() public {

        emit log_named_decimal_uint("User2 Balance before minting BTC",
                                    IERC20(ERCBondingCurveContract.reserveTokenAddress()).balanceOf(address(this))
                                    , 18);

        vm.startPrank(User2);
        emit log_named_decimal_uint("User2 Balance in USDT before minting BTC",
                                    USDTTokenContract.balanceOf(address(User2)), 18);

        vm.startPrank(User1);
        emit log_named_decimal_uint("User1 Balance in USDT before minting BTC",
                                    USDTTokenContract.balanceOf(address(User1)), 18);


    }
    

}





contract USDT is ERC20 {
    constructor() ERC20("USDT tokens", "USDT") {
        _mint(msg.sender, 100 * 10 ** 18);
    }   
}
