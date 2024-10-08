// SPDX-License-Identifier: Apache 2.0
pragma solidity 0.8.23;

import {CommonBase} from "forge-std/Base.sol";

contract SemaphoreCheatsUtils is CommonBase {
    function stringToBytes32(
        string memory source
    ) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}
