// SPDX-License-Identifier: Apache 2.0
pragma solidity 0.8.23;

import {ISemaphore} from "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";
import {ISemaphoreVerifier} from "@semaphore-protocol/contracts/interfaces/ISemaphoreVerifier.sol";
import {ISemaphoreGroups} from "@semaphore-protocol/contracts/interfaces/ISemaphoreGroups.sol";
import {SemaphoreVerifier} from "@semaphore-protocol/contracts/base/SemaphoreVerifier.sol";
import {Semaphore} from "@semaphore-protocol/contracts/Semaphore.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Test, console} from "forge-std/Test.sol";
import {SemaphoreCheats} from "./SemaphoreCheats.sol";
import {SemaphoreCheatsUtils} from "./SemaphoreCheatsUtils.sol";
import {Feedback} from "../src/Feedback.sol";

contract FeedbackTest is Test, SemaphoreCheats, SemaphoreCheatsUtils {
    ISemaphore public semaphore;
    Feedback public feedback;
    uint256 public groupID;

    function setUp() public {
        deploySemaphore();

        feedback = new Feedback(address(semaphore));
        groupID = feedback.groupId();
    }

    function deploySemaphore() public {
        SemaphoreVerifier semaphoreVerifier = new SemaphoreVerifier();
        semaphore = new Semaphore(
            ISemaphoreVerifier(address(semaphoreVerifier))
        );
    }

    function test_shouldJoinGroup() public {
        SemaphoreCheatIdentity[] memory users = new SemaphoreCheatIdentity[](2);

        users[0] = generateIdentity();
        users[1] = generateIdentity();

        for (uint256 i = 0; i < users.length; i++) {
            SemaphoreCheatIdentity[]
                memory currentUsers = new SemaphoreCheatIdentity[](i + 1);

            for (uint256 j = 0; j <= i; j++) {
                currentUsers[j] = users[j];
            }

            SemaphoreCheatGroup memory semaphoreGroup = generateGroup(
                currentUsers
            );

            vm.expectEmit();
            emit ISemaphoreGroups.MemberAdded(
                groupID,
                i,
                users[i].commitment,
                semaphoreGroup.root
            );

            feedback.joinGroup(users[i].commitment);
        }
    }

    function test_shouldSendFeedbackAnonymously() public {
        SemaphoreCheatIdentity[] memory users = new SemaphoreCheatIdentity[](2);

        users[0] = generateIdentity();
        users[1] = generateIdentity();

        for (uint256 i = 0; i < users.length; i++) {
            feedback.joinGroup(users[i].commitment);
        }

        string memory feedbackToEmit = "Hello World";

        SemaphoreCheatProof memory semaphoreProof = generateProof(
            users[0],
            users,
            feedbackToEmit,
            Strings.toString(groupID)
        );

        vm.expectEmit();
        emit ISemaphore.ProofValidated(
            groupID,
            semaphoreProof.merkleTreeDepth,
            semaphoreProof.merkleTreeRoot,
            semaphoreProof.nullifier,
            semaphoreProof.message,
            groupID,
            semaphoreProof.points
        );

        feedback.sendFeedback(
            semaphoreProof.merkleTreeDepth,
            semaphoreProof.merkleTreeRoot,
            semaphoreProof.nullifier,
            uint256(stringToBytes32(feedbackToEmit)),
            semaphoreProof.points
        );
    }

    function test_shouldFailToSendFeedbackAnonymously() public {
        SemaphoreCheatIdentity[] memory users = new SemaphoreCheatIdentity[](2);

        users[0] = generateIdentity();
        users[1] = generateIdentity();

        for (uint256 i = 0; i < users.length; i++) {
            feedback.joinGroup(users[i].commitment);
        }

        string memory feedbackToEmit = "Hello World";

        SemaphoreCheatProof memory semaphoreProof = generateProof(
            users[0],
            users,
            feedbackToEmit,
            Strings.toString(groupID)
        );

        string memory wrongFeedback = "World Hello";

        vm.expectRevert(ISemaphore.Semaphore__InvalidProof.selector);
        feedback.sendFeedback(
            semaphoreProof.merkleTreeDepth,
            semaphoreProof.merkleTreeRoot,
            semaphoreProof.nullifier,
            uint256(stringToBytes32(wrongFeedback)),
            semaphoreProof.points
        );
    }
}
