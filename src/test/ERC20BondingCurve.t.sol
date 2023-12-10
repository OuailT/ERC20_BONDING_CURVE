
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../ERC20BondingCurve.sol";


contract TestBondedToken is Test {


    event MintTokens(address indexed Minter, uint256 amountToMint);
    event BurnedTokens(address indexed Burner, uint256 _amountToBurn, uint256 payBackAmount);

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
        USDTTokenContract.transfer(User2, 200 ether);

    }

    // Call the function that calculate the the mintamount based on the deposit after minting
    // The amount returned by that function should be equal to amount of BTC token received by the user.
    function testMintingTokensSuccessfully() public {

        emit log_named_decimal_uint("Address(this) Balance in BTC",
                                    IERC20(ERCBondingCurveContract).balanceOf(address(this))
                                    , 18);
        
        emit log_named_decimal_uint("Address(this) Balance in USDT before minting BTC",
                                    USDTTokenContract.balanceOf(address(this))
                                    , 18);

        emit log_named_decimal_uint("User2 Balance in USDT before minting BTC",
                                    USDTTokenContract.balanceOf(address(User2)), 18);


        vm.startPrank(User1);

        console.log("-------------------------User1-----------------------------");

        emit log_named_decimal_uint("User1 Balance in USDT before minting BTC",
                                    USDTTokenContract.balanceOf(address(User1)),
                                     18);

        emit log_named_decimal_uint("User1 Balance in BTC before ",
                                    IERC20(ERCBondingCurveContract).balanceOf(address(User1))
                                    , 18);
        
        emit log_named_decimal_uint("Current BTC price before user1 mint ",
                                    ERCBondingCurveContract.getBTCPrice()
                                    , 18);

        USDTTokenContract.approve(address(ERCBondingCurveContract), 50 ether);

        uint256 user1ExpMintReturn = ERCBondingCurveContract.calculateContinuousMintReturn(50 ether);

        ERCBondingCurveContract.mint(50 ether);

        uint256 use1BTCBalance = IERC20(ERCBondingCurveContract).balanceOf(address(User1));
        uint256 user1USDTBalance = USDTTokenContract.balanceOf(address(User1));
        uint256 poolBalAfterUser1Mint = IERC20(USDTTokenContract).balanceOf(address(ERCBondingCurveContract));

        emit log_named_decimal_uint("Current BTC price after user1 mint ",
                                    ERCBondingCurveContract.getBTCPrice()
                                    , 18);

        emit log_named_decimal_uint("User1 Balance in USDT after minting BTC", user1USDTBalance, 18);
        emit log_named_decimal_uint("User1 Balance in BTC after", use1BTCBalance , 18);

        // Check if User1's BTC balance matches the expected mint return
        assertEq(use1BTCBalance , user1ExpMintReturn, " User1 BTC balance incorrect");

        // Check if User1's USDT balance is zero after minting
        assertEq(user1USDTBalance, 0, "User1 USDT balance should be zero");

        // Check if the bonding curve contract reserve balance increased correctly after User1's deposit
        assertEq(poolBalAfterUser1Mint, 50 ether, "Reserve should increase by 50 USDT after User1 deposit");

        console.log("------------------------------------------------------");

        vm.stopPrank();



        vm.startPrank(User2);

        console.log("-------------------------User2-----------------------------");

        emit log_named_decimal_uint("User2 Balance in USDT before minting BTC",
                                    USDTTokenContract.balanceOf(address(User2)),
                                     18);

        emit log_named_decimal_uint("User2 Balance in BTC before ",
                                    IERC20(ERCBondingCurveContract).balanceOf(address(User2))
                                    , 18);
        
        emit log_named_decimal_uint("Current BTC price before user2 mint ",
                                    ERCBondingCurveContract.getBTCPrice()
                                    , 18);

        USDTTokenContract.approve(address(ERCBondingCurveContract), 200 ether);

        uint256 user2ExpMintReturn = ERCBondingCurveContract.calculateContinuousMintReturn(200 ether);

        ERCBondingCurveContract.mint(200 ether);

        uint256 use2BTCBalance = IERC20(ERCBondingCurveContract).balanceOf(address(User2));
        uint256 user2USDTBalance = USDTTokenContract.balanceOf(address(User2));
        uint256 poolBalAfterUser2Mint = IERC20(USDTTokenContract).balanceOf(address(ERCBondingCurveContract));

        emit log_named_decimal_uint("Current BTC price after user2 mint ",
                                    ERCBondingCurveContract.getBTCPrice()
                                    , 18);

        // How do I know The currentPrice of the token;
        emit log_named_decimal_uint("User2 Balance in USDT after minting BTC",
                                    user2USDTBalance , 18);

        emit log_named_decimal_uint("User2 Balance in BTC after",
                                    use2BTCBalance, 18);
        
        emit log_named_decimal_uint("User2 Balance in BTC after",
                                    use2BTCBalance, 18);
    
        // Check if User1's BTC balance matches the expected mint return
        assertEq(use2BTCBalance , user2ExpMintReturn, " User2 BTC balance incorrect");

        // Check if User2's USDT balance is zero after minting
        assertEq(user2USDTBalance, 0, "User2 USDT balance should be zero");

        // Check if the bonding curve contract reserve balance increased correctly after User2's deposit
        assertEq(poolBalAfterUser2Mint, 250 ether, "Reserve should increase by 50 USDT after User2 deposit");

        console.log("--------------------------------------------------------------------------");

        emit log_named_decimal_uint("Bonding curve contract Reserve/Pool/Balance ",
                                    poolBalAfterUser2Mint,
                                    18);

        vm.stopPrank();
       
    }


    // stopped at test emit event
    function testMintEventEmit() public {
        testMintingTokensSuccessfully();
        
        vm.expectEmit()
        emit MintTokens(address(User1), ) 



    }


    function testExpectRevertNotEnoughAllowance() public {
        vm.startPrank(User1);
            USDTTokenContract.transfer(User1, 50 ether);
            USDTTokenContract.approve(address(ERCBondingCurveContract), 40 ether);
            vm.expectRevert("NOT_ENOUGH_ALLOWANCE");
            ERCBondingCurveContract.mint(50 ether);
        vm.stopPrank();
    }


    // Specify what exactly this function is testing in the Natspec    
    function testBurningTokensSuccessfully() public {
        testMintingTokensSuccessfully();

        console.log("----------------------------The Burrrn User1----------------------------------------------");

        vm.startPrank(User1);

        uint256 use1BTCBalancebef = IERC20(ERCBondingCurveContract).balanceOf(address(User1));
        uint256 user1ExpBurnReturn = ERCBondingCurveContract.calculateContinuousBurnReturn(use1BTCBalancebef);

        console.log("user1ExpBurnReturn",user1ExpBurnReturn);

        emit log_named_decimal_uint("User1 Balance in USDT before Burning BTC", USDTTokenContract.balanceOf(address(User1)), 18);

        ERCBondingCurveContract.burn(use1BTCBalancebef);

        uint256 use1BTCBalanceAft = IERC20(ERCBondingCurveContract).balanceOf(address(User1));
        uint256 user1USDTBalance = USDTTokenContract.balanceOf(address(User1));
        uint256 poolBalAfterUser1Burn = IERC20(USDTTokenContract).balanceOf(address(ERCBondingCurveContract));
        
        emit log_named_decimal_uint("User1 Balance in USDT after Burning BTC",
                                     user1USDTBalance, 18);
        emit log_named_decimal_uint("User1 Balance in BTC after",
                                     use1BTCBalanceAft , 18);
        emit log_named_decimal_uint("Bonding curve contract Reserve/Pool/Balance",
                                     poolBalAfterUser1Burn , 18);
        
        // Check if User1's BTC balance is is zero after Burning all his BTC balance
        assertEq(use1BTCBalanceAft , 0, " User1 BTC balance Should be zero after burn");

        // // Check if User1's USDT balance match the expected burn return
        assertEq(user1USDTBalance, user1ExpBurnReturn, "User2 USDT balance Incorrect");

        // // Check if the bonding curve contract reserve balance decreased correctly after User2'1 Burn/Withdraw
        assertEq(poolBalAfterUser1Burn, 250 ether - user1ExpBurnReturn, "Reserve should decrease by expect burn return after User2 Burn");
        
        console.log("---------------------------------------------------------------------------------");

        vm.stopPrank();

    }


    function testExpectRevertNotEnoughTokensToBurn() public {
        testMintingTokensSuccessfully();
        vm.startPrank(User1);
             uint256 use1BalBTCToBurn = IERC20(ERCBondingCurveContract).balanceOf(address(User1));
            vm.expectRevert("Insufficient token balance to burn");
            ERCBondingCurveContract.burn(use1BalBTCToBurn + 1);
        vm.stopPrank();
    }






}





contract USDT is ERC20 {
    constructor() ERC20("USDT tokens", "USDT") {
        _mint(msg.sender, 100000 * 10 ** 18);
    }   
}
