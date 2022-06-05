// SPDX-License-Identifier: MIT
// File: contracts/library/BridgeScanRange.sol

pragma solidity ^0.8.7;

struct AbnormalRangeInfo {
    bool startInit;
    bool endInit;
    uint256 startIndex;
    uint256 endIndex;
    bool continuousStart;
    bool continuousEnd;
    bool middle;
}

library BridgeScanRange {
    function getBlockScanRange(
        uint64[] memory r,
        uint64 v1,
        uint64 v2
    ) internal pure returns (uint64[] memory _r) {
        if (r.length == 0) {
            _r = new uint64[](2);
            (, _r) = _insertRange(0, _r, v1, v2);
        } else {
            uint256 total;
            uint64[2][] memory ranges = _extractBlockScanRanges(r);
            bool normality = _determineRangeNormality(ranges, v1, v2);
            if (normality) {
                total = _getNewRangeCount(r.length, ranges, v1, v2);
                if (total > 0) {
                    _r = new uint64[](total);
                    _r = _createNewRanges(ranges, v1, v2, _r);
                }
            } else {
                AbnormalRangeInfo memory info;
                (total, info) = _getAbnormalNewRangeCount(
                    r.length,
                    ranges,
                    v1,
                    v2
                );
                if (total > 0) {
                    _r = new uint64[](total);
                    _r = _createAbnormalNewRanges(ranges, v1, v2, _r, info);
                }
            }

            if (total == 0) {
                _r = new uint64[](r.length);
                _r = r;
            }
        }
    }

    // extract [x1, x2, x3, x4] into [[x1, x2], [x3, x4]]
    function _extractBlockScanRanges(uint64[] memory r)
        private
        pure
        returns (uint64[2][] memory arr)
    {
        uint256 maxRange = r.length / 2;
        arr = new uint64[2][](maxRange);

        uint64 k = 0;
        for (uint64 i = 0; i < maxRange; i++) {
            (bool e1, uint64 v1) = _getElement(i + k, r);
            (bool e2, uint64 v2) = _getElement(i + k + 1, r);

            uint64[2] memory tmp;
            if (e1 && e2) tmp = [v1, v2];
            arr[k] = tmp;
            k++;
        }
    }

    function _getElement(uint64 i, uint64[] memory arr)
        private
        pure
        returns (bool exist, uint64 ele)
    {
        if (exist = (i >= 0 && i < arr.length)) {
            ele = arr[i];
        }
    }

    function _getElement(uint64 i, uint64[2][] memory arr)
        private
        pure
        returns (bool exist, uint64[2] memory ranges)
    {
        if (exist = (i >= 0 && i < arr.length)) {
            ranges = arr[i];
        }
    }

    // determine range overlapping
    function _determineRangeNormality(
        uint64[2][] memory ranges,
        uint64 v1,
        uint64 v2
    ) private pure returns (bool normality) {
        bool ended;
        for (uint64 i = 0; i < ranges.length; i++) {
            (bool e1, uint64[2] memory ele1) = _getElement(i, ranges);
            (bool e2, uint64[2] memory ele2) = _getElement(i + 1, ranges);

            if (e1 && e2)
                (ended, normality) = _checkRangeNormality(
                    i,
                    v1,
                    v2,
                    ele1,
                    ele2
                );
            else if (e1)
                (ended, normality) = _checkRangeNormality(i, v1, v2, ele1);

            if (ended) return normality;
        }
    }

    function _checkRangeNormality(
        uint64 index,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1
    ) private pure returns (bool, bool) {
        if ((index == 0 && v2 <= ele1[0]) || v1 >= ele1[1]) {
            return (true, true);
        }
        return (true, false);
    }

    function _checkRangeNormality(
        uint64 index,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1,
        uint64[2] memory ele2
    ) private pure returns (bool, bool) {
        if ((index == 0 && v2 <= ele1[0]) || (v1 >= ele1[1] && v2 <= ele2[0])) {
            return (true, true);
        }
        return (false, false);
    }

    /** Range Normal */

    // Get total number of elements
    function _getNewRangeCount(
        uint256 curCount,
        uint64[2][] memory ranges,
        uint64 v1,
        uint64 v2
    ) private pure returns (uint256 total) {
        for (uint64 i = 0; i < ranges.length; i++) {
            (bool e1, uint64[2] memory ele1) = _getElement(i, ranges);
            (bool e2, uint64[2] memory ele2) = _getElement(i + 1, ranges);

            if (e1 && e2) total = _calculateRange(curCount, v1, v2, ele1, ele2);
            else if (e1) total = _calculateRange(curCount, v1, v2, ele1);

            if (total > 0) return total;
        }
        return total;
    }

    function _calculateRange(
        uint256 curCount,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1
    ) private pure returns (uint256 total) {
        if (v2 <= ele1[0]) {
            if (_checkEnd(ele1[0], v2)) {
                total = curCount;
            } else {
                total = curCount + 2;
            }
        } else if (v1 >= ele1[1]) {
            if (_checkStart(ele1[1], v1)) {
                total = curCount;
            } else {
                total = curCount + 2;
            }
        }
    }

    function _calculateRange(
        uint256 curCount,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1,
        uint64[2] memory ele2
    ) private pure returns (uint256 total) {
        if (v2 <= ele1[0]) {
            if (_checkEnd(ele1[0], v2)) {
                total = curCount;
            } else {
                total = curCount + 2;
            }
        } else if (v1 >= ele1[1] && v2 <= ele2[0]) {
            if (_checkStart(ele1[1], v1) && _checkEnd(ele2[0], v2)) {
                total = curCount - 2;
            } else if (_checkStart(ele1[1], v1) || _checkEnd(ele2[0], v2)) {
                total = curCount;
            } else {
                total = curCount + 2;
            }
        }
    }

    // Create new blockScanRanges array
    function _createNewRanges(
        uint64[2][] memory ranges,
        uint64 v1,
        uint64 v2,
        uint64[] memory r
    ) private pure returns (uint64[] memory) {
        bool done = false;
        bool skip = false;
        uint256 total = 0;
        for (uint64 i = 0; i < ranges.length; i++) {
            (bool e1, uint64[2] memory ele1) = _getElement(i, ranges);
            (bool e2, uint64[2] memory ele2) = _getElement(i + 1, ranges);

            if (done) {
                if (!skip && e1)
                    (total, r) = _insertRange(total, r, ele1[0], ele1[1]);
                else skip = false;
            } else {
                if (e1 && e2) {
                    (done, total, r) = _insertRange(
                        total,
                        r,
                        v1,
                        v2,
                        ele1,
                        ele2
                    );
                    if (done) skip = true;
                } else if (e1)
                    (done, total, r) = _insertRange(total, r, v1, v2, ele1);
            }
        }
        return r;
    }

    function _insertRange(
        uint256 i,
        uint64[] memory r,
        uint64 v1,
        uint64 v2
    ) private pure returns (uint256, uint64[] memory) {
        r[i] = v1;
        r[i + 1] = v2;
        i += 2;
        return (i, r);
    }

    function _insertRange(
        uint256 i,
        uint64[] memory r,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1
    )
        private
        pure
        returns (
            bool done,
            uint256,
            uint64[] memory
        )
    {
        if (v2 <= ele1[0]) {
            if (_checkEnd(ele1[0], v2)) {
                (i, r) = _insertRange(i, r, v1, ele1[1]);
                done = true;
            } else {
                (i, r) = _insertRange(i, r, v1, v2);
                (i, r) = _insertRange(i, r, ele1[0], ele1[1]);
                done = true;
            }
        } else if (v1 >= ele1[1]) {
            if (_checkStart(ele1[1], v1)) {
                (i, r) = _insertRange(i, r, ele1[0], v2);
                done = true;
            } else {
                (i, r) = _insertRange(i, r, ele1[0], ele1[1]);
                (i, r) = _insertRange(i, r, v1, v2);
                done = true;
            }
        }
        return (done, i, r);
    }

    function _insertRange(
        uint256 i,
        uint64[] memory r,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1,
        uint64[2] memory ele2
    )
        private
        pure
        returns (
            bool done,
            uint256,
            uint64[] memory
        )
    {
        if (v2 <= ele1[0]) {
            if (_checkEnd(ele1[0], v2)) {
                (i, r) = _insertRange(i, r, v1, ele1[1]);
                (i, r) = _insertRange(i, r, ele2[0], ele2[1]);
                done = true;
            } else {
                (i, r) = _insertRange(i, r, v1, v2);
                (i, r) = _insertRange(i, r, ele1[0], ele1[1]);
                (i, r) = _insertRange(i, r, ele2[0], ele2[1]);
                done = true;
            }
        } else if (v1 >= ele1[1] && v2 <= ele2[0]) {
            if (_checkStart(ele1[1], v1) && _checkEnd(ele2[0], v2)) {
                (i, r) = _insertRange(i, r, ele1[0], ele2[1]);
                done = true;
            } else if (_checkStart(ele1[1], v1)) {
                (i, r) = _insertRange(i, r, ele1[0], v2);
                (i, r) = _insertRange(i, r, ele2[0], ele2[1]);
                done = true;
            } else if (_checkEnd(ele2[0], v2)) {
                (i, r) = _insertRange(i, r, ele1[0], ele1[1]);
                (i, r) = _insertRange(i, r, v1, ele2[1]);
                done = true;
            } else {
                (i, r) = _insertRange(i, r, ele1[0], ele1[1]);
                (i, r) = _insertRange(i, r, v1, v2);
                (i, r) = _insertRange(i, r, ele2[0], ele2[1]);
                done = true;
            }
        }

        if (!done) (i, r) = _insertRange(i, r, ele1[0], ele1[1]);

        return (done, i, r);
    }

    /** END Range Normal */

    /** Range Abnormal (overlapping) */
    function _getAbnormalNewRangeCount(
        uint256 curCount,
        uint64[2][] memory ranges,
        uint64 v1,
        uint64 v2
    ) private pure returns (uint256 total, AbnormalRangeInfo memory info) {
        for (uint64 i = 0; i < ranges.length; i++) {
            (bool e1, uint64[2] memory ele1) = _getElement(i, ranges);
            (bool e2, uint64[2] memory ele2) = _getElement(i + 1, ranges);

            if (e1 && e2) {
                if (info.startInit)
                    info = _calculateAbnormalRangeEnd(i, v2, ele1, ele2, info);
                else
                    info = _calculateAbnormalRange(i, v1, v2, ele1, ele2, info);
            } else if (e1) {
                if (info.startInit)
                    info = _calculateAbnormalRange(i, v2, ele1, info);
                else info = _calculateAbnormalRange(i, v1, v2, ele1, info);
            }

            if (info.endInit)
                total = _calculateAbnormalRangeTotal(curCount, info);

            if (total > 0) return (total, info);
        }
    }

    function _calculateAbnormalRange(
        uint256 i,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1,
        AbnormalRangeInfo memory info
    ) private pure returns (AbnormalRangeInfo memory) {
        if (v1 <= ele1[0] && v2 >= ele1[1]) {
            info.startInit = info.endInit = true;
            info.startIndex = info.endIndex = i;
        }
        return info;
    }

    function _calculateAbnormalRange(
        uint256 i,
        uint64 v2,
        uint64[2] memory ele1,
        AbnormalRangeInfo memory info
    ) private pure returns (AbnormalRangeInfo memory) {
        if (v2 >= ele1[1]) {
            info.endInit = true;
            info.endIndex = i;
        }
        return info;
    }

    function _calculateAbnormalRange(
        uint256 i,
        uint64 v1,
        uint64 v2,
        uint64[2] memory ele1,
        uint64[2] memory ele2,
        AbnormalRangeInfo memory info
    ) private pure returns (AbnormalRangeInfo memory) {
        if (v1 <= ele1[0] && v2 >= ele1[1] && v2 <= ele2[0]) {
            info.startInit = info.endInit = true;
            info.startIndex = info.endIndex = i;
            if (_checkEnd(ele2[0], v2)) info.continuousEnd = true;
        } else if (v1 <= ele1[0]) {
            info.startInit = true;
            info.startIndex = i;
        } else if (v1 >= ele1[1] && v1 <= ele2[0]) {
            info.startInit = true;
            info.startIndex = i;
            info.middle = true;
            if (_checkStart(ele1[1], v1)) info.continuousStart = true;
        }
        return info;
    }

    function _calculateAbnormalRangeEnd(
        uint256 i,
        uint64 v2,
        uint64[2] memory ele1,
        uint64[2] memory ele2,
        AbnormalRangeInfo memory info
    ) private pure returns (AbnormalRangeInfo memory) {
        if (v2 >= ele1[1] && v2 <= ele2[0]) {
            info.endInit = true;
            info.endIndex = i;
            if (_checkEnd(ele2[0], v2)) info.continuousEnd = true;
        }
        return info;
    }

    function _calculateAbnormalRangeTotal(
        uint256 curCount,
        AbnormalRangeInfo memory info
    ) private pure returns (uint256 total) {
        if (info.startIndex == info.endIndex) {
            if (info.continuousEnd) total = curCount - 2;
            else total = curCount;
        } else if (info.endIndex > info.startIndex) {
            uint256 diff = info.endIndex - info.startIndex;
            total = curCount - (2 * diff);
            if (
                (info.continuousStart && info.continuousEnd && info.middle) ||
                (info.continuousEnd && !info.middle)
            ) total -= 2;
            else if (
                !info.continuousStart && !info.continuousEnd && info.middle
            ) total += 2;
        }
    }

    function _createAbnormalNewRanges(
        uint64[2][] memory ranges,
        uint64 v1,
        uint64 v2,
        uint64[] memory r,
        AbnormalRangeInfo memory info
    ) private pure returns (uint64[] memory) {
        bool skip = false;
        uint256 total = 0;
        for (uint64 i = 0; i < ranges.length; i++) {
            (, uint64[2] memory ele1) = _getElement(i, ranges);
            (bool e2, uint64[2] memory ele2) = _getElement(i + 1, ranges);

            if (info.startIndex == i) {
                if (info.middle) {
                    if (info.continuousStart) {
                        (total, r) = _insertAbnormalRange(total, r, ele1[0]);
                        skip = true;
                    } else {
                        (total, r) = _insertAbnormalRange(
                            total,
                            r,
                            ele1[0],
                            ele1[1]
                        );
                        (total, r) = _insertAbnormalRange(total, r, v1);
                        skip = true;
                    }
                } else {
                    (total, r) = _insertAbnormalRange(total, r, v1);
                }
            }

            if (info.endIndex == i) {
                if (info.continuousEnd) {
                    (total, r) = _insertAbnormalRange(total, r, ele2[1]);
                    skip = true;
                } else {
                    (total, r) = _insertAbnormalRange(total, r, v2);
                    if (e2) {
                        (total, r) = _insertAbnormalRange(
                            total,
                            r,
                            ele2[0],
                            ele2[1]
                        );
                        skip = true;
                    }
                }
            }

            if (!(i >= info.startIndex && i <= info.endIndex)) {
                if (!skip)
                    (total, r) = _insertAbnormalRange(
                        total,
                        r,
                        ele1[0],
                        ele1[1]
                    );
                else skip = false;
            }
        }
        return r;
    }

    function _insertAbnormalRange(
        uint256 i,
        uint64[] memory r,
        uint64 v
    ) private pure returns (uint256, uint64[] memory) {
        r[i] = v;
        i += 1;
        return (i, r);
    }

    function _insertAbnormalRange(
        uint256 i,
        uint64[] memory r,
        uint64 v1,
        uint64 v2
    ) private pure returns (uint256, uint64[] memory) {
        r[i] = v1;
        r[i + 1] = v2;
        i += 2;
        return (i, r);
    }

    /** END Range Abnormal (overlapping) */

    // Check continuous
    function _checkStart(uint64 ele, uint64 v) private pure returns (bool) {
        return ((uint64(ele + 1) == v) || ele == v);
    }

    function _checkEnd(uint64 ele, uint64 v) private pure returns (bool) {
        return ((uint64(ele - 1) == v) || ele == v);
    }
}

// File: contracts/library/BridgeSecurity.sol

pragma solidity ^0.8.7;

library BridgeSecurity {
    function generateSignerMsgHash(uint64 epoch, address[] memory signers)
        internal
        pure
        returns (bytes32 msgHash)
    {
        msgHash = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                address(0),
                epoch,
                _encodeAddressArr(signers)
            )
        );
    }

    function generatePackMsgHash(
        address thisAddr,
        uint64 epoch,
        uint8 networkId,
        uint64[2] memory blockScanRange,
        uint256[] memory txHashes,
        address[] memory tokens,
        address[] memory recipients,
        uint256[] memory amounts
    ) internal pure returns (bytes32 msgHash) {
        msgHash = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                thisAddr,
                epoch,
                _encodeFixed2Uint64Arr(blockScanRange),
                networkId,
                _encodeUint256Arr(txHashes),
                _encodeAddressArr(tokens),
                _encodeAddressArr(recipients),
                _encodeUint256Arr(amounts)
            )
        );
    }

    function signersVerification(
        bytes32 msgHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s,
        address[] memory signers,
        mapping(address => bool) storage mapSigners
    ) internal view returns (bool) {
        uint64 totalSigners = 0;
        for (uint64 i = 0; i < signers.length; i++) {
            if (mapSigners[signers[i]]) totalSigners++;
        }
        return (_getVerifiedSigners(msgHash, v, r, s, mapSigners) ==
            (totalSigners / 2) + 1);
    }

    function _getVerifiedSigners(
        bytes32 msgHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s,
        mapping(address => bool) storage mapSigners
    ) private view returns (uint8 verifiedSigners) {
        address lastAddr = address(0);
        verifiedSigners = 0;
        for (uint64 i = 0; i < v.length; i++) {
            address recovered = ecrecover(msgHash, v[i], r[i], s[i]);
            if (recovered > lastAddr && mapSigners[recovered])
                verifiedSigners++;
            lastAddr = recovered;
        }
    }

    function _encodeAddressArr(address[] memory arr)
        private
        pure
        returns (bytes memory data)
    {
        for (uint64 i = 0; i < arr.length; i++) {
            data = abi.encodePacked(data, arr[i]);
        }
    }

    function _encodeUint256Arr(uint256[] memory arr)
        private
        pure
        returns (bytes memory data)
    {
        for (uint64 i = 0; i < arr.length; i++) {
            data = abi.encodePacked(data, arr[i]);
        }
    }

    function _encodeFixed2Uint64Arr(uint64[2] memory arr)
        private
        pure
        returns (bytes memory data)
    {
        for (uint64 i = 0; i < arr.length; i++) {
            data = abi.encodePacked(data, arr[i]);
        }
    }
}

// File: contracts/BaseToken/interface/ITokenFactory.sol

pragma solidity ^0.8.7;

interface ITokenFactory {
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event BridgeChanged(address indexed oldBridge, address indexed newBridge);

    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    event TokenCreated(
        string name,
        string indexed symbol,
        uint256 amount,
        uint256 cap,
        address indexed token
    );

    event TokenRemoved(address indexed token);

    function owner() external view returns (address);

    function tokens() external view returns (address[] memory);

    function tokenExist(address token) external view returns (bool);

    function bridge() external view returns (address);

    function admin() external view returns (address);

    function setBridge(address bridge) external;

    function setAdmin(address admin) external;

    function createToken(
        string memory name,
        string memory symbol,
        uint256 amount,
        uint256 cap
    ) external returns (address token);

    function removeToken(address token) external;
}

// File: contracts/BaseCrossBridge/interface/ICrossBridgeStorageToken.sol

pragma solidity ^0.8.7;

interface ICrossBridgeStorageToken {
    event TokenConnected(
        address indexed token,
        uint256 amount,
        uint256 percent,
        address indexed crossToken,
        string symbol
    );

    event TokenRequirementChanged(
        uint64 blockIndex,
        address indexed token,
        uint256[2] amount,
        uint256[2] percent
    );

    function owner() external view returns (address);

    function admin() external view returns (address);

    function bridge() external view returns (address);

    function mapToken(address token) external view returns (bool);

    function mapOcToken(address token) external view returns (address);

    function mapCoToken(address token) external view returns (address);

    function blockScanRange() external view returns (uint64[] memory);

    function crossToken(address token)
        external
        view
        returns (string memory, string memory);

    function tokens(
        ITokenFactory tf,
        uint64 futureBlock,
        uint64 searchBlockIndex
    )
        external
        view
        returns (
            uint8[] memory,
            address[][] memory,
            address[][] memory,
            uint256[][] memory,
            uint256[][] memory,
            uint8[][] memory
        );

    function tokens(
        ITokenFactory tf,
        uint8 id,
        uint64 futureBlock,
        uint64 searchBlockIndex
    )
        external
        view
        returns (
            address[] memory,
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            uint8[] memory
        );

    function charges()
        external
        view
        returns (address[] memory tokens, uint256[] memory charges);

    function txHash(uint256 txHash) external view returns (bool);

    function transactionInfo(
        uint64 futureBlock,
        address token,
        uint256 amount
    ) external view returns (uint256 fee, uint256 amountAfterCharge);

    function setCallers(address admin, address bridge) external;

    function resetConnection(address token, address crossToken) external;

    function setConnection(
        address token,
        uint256 amount,
        uint256 percent,
        address crossToken,
        string memory name,
        string memory symbol
    ) external;

    function setInfo(
        address token,
        uint256 amount,
        uint256 percent
    ) external;

    function setAmount(address token, uint256 amount) external;

    function setPercent(address token, uint256 percent) external;

    function setTxHash(uint256 txHash) external;

    function setCollectedCharges(address token, uint256 amount) external;

    function setScanRange(uint64[2] memory scanRange) external;
}

// File: contracts/BaseBridge/interface/IBridge.sol

pragma solidity ^0.8.7;

struct TokenReq {
    bool exist;
    uint256 minAmount;
    uint256 chargePercent;
}

struct CrossTokenInfo {
    string name;
    string symbol;
}

struct NetworkInfo {
    uint8 id;
    string name;
}

struct TokenData {
    address[] tokens;
    address[] crossTokens;
    uint256[] minAmounts;
    uint256[] chargePercents;
    uint8[] tokenTypes;
}

struct TokensInfo {
    uint8[] ids;
    address[][] tokens;
    address[][] crossTokens;
    uint256[][] minAmounts;
    uint256[][] chargePercents;
    uint8[][] tokenTypes;
}

struct TokensChargesInfo {
    uint8[] ids;
    address[][] tokens;
    uint256[][] charges;
}

interface IBridge {
    event TokenConnected(
        address indexed token,
        uint256 amount,
        uint256 percent,
        address indexed crossToken,
        string symbol
    );

    event TokenReqChanged(
        uint64 blockIndex,
        address indexed token,
        uint256[2] amount,
        uint256[2] percent
    );

    function initialize(
        address factory,
        address admin,
        address tokenFactory,
        address wMech,
        uint8 id,
        string memory name
    ) external;

    function factory() external view returns (address);

    function admin() external view returns (address);

    function network() external view returns (uint8, string memory);

    function activeTokenCount() external view returns (uint8);

    function crossToken(address crossToken)
        external
        view
        returns (string memory, string memory);

    function tokens(uint64 futureBlock, uint64 searchBlockIndex)
        external
        view
        returns (TokenData memory data);

    function blockScanRange() external view returns (uint64[] memory);

    function charges()
        external
        view
        returns (address[] memory tokens, uint256[] memory charges);

    function txHash(uint256 txHash_) external view returns (bool);

    function setConnection(
        address token,
        uint256 amount,
        uint256 percent,
        address crossToken,
        string memory name,
        string memory symbol
    ) external;

    function setInfo(
        address token,
        uint256 amount,
        uint256 percent
    ) external;

    function setAmount(address token, uint256 amount) external;

    function setPercent(address token, uint256 percent) external;

    function resetConnection(address token, address crossToken) external;

    function processPack(
        uint64[2] memory blockScanRange,
        uint256[] memory txHashes,
        address[] memory tokens,
        address[] memory recipients,
        uint256[] memory amounts
    ) external;
}

// File: contracts/library/BridgeUtils.sol

pragma solidity ^0.8.7;

library BridgeUtils {
    uint256 internal constant FUTURE_BLOCK_INTERVAL = 100;
    uint256 public constant CHARGE_PERCENTAGE_DIVIDER = 10000;

    function roundFuture(uint256 blockIndex) internal pure returns (uint64) {
        uint256 _futureBlockIndex;
        if (blockIndex <= FUTURE_BLOCK_INTERVAL) {
            _futureBlockIndex = FUTURE_BLOCK_INTERVAL;
        } else {
            _futureBlockIndex =
                FUTURE_BLOCK_INTERVAL *
                ((blockIndex / FUTURE_BLOCK_INTERVAL) + 1);
        }
        return uint64(_futureBlockIndex);
    }

    function getFuture(uint256 blockIndex)
        internal
        pure
        returns (uint64 futureBlockIndex)
    {
        uint256 _futureBlockIndex;
        if (blockIndex <= FUTURE_BLOCK_INTERVAL) {
            _futureBlockIndex = 0;
        } else {
            _futureBlockIndex =
                FUTURE_BLOCK_INTERVAL *
                (blockIndex / FUTURE_BLOCK_INTERVAL);
        }
        return uint64(_futureBlockIndex);
    }

    function getBlockScanRange(
        uint16 count,
        uint8[] memory networks,
        mapping(uint8 => address) storage bridges
    )
        internal
        view
        returns (uint8[] memory _networks, uint64[][] memory _ranges)
    {
        _networks = new uint8[](count);
        _ranges = new uint64[][](count);
        uint64 k = 0;
        for (uint64 i = 0; i < networks.length; i++) {
            if (bridges[networks[i]] != address(0)) {
                _networks[k] = networks[i];
                _ranges[k] = IBridge(bridges[networks[i]]).blockScanRange();
                k++;
            }
        }
    }

    function getCharges(
        uint16 count,
        uint8[] memory networks,
        mapping(uint8 => address) storage bridges
    ) internal view returns (TokensChargesInfo memory info) {
        uint8[] memory _networks = new uint8[](count);
        address[][] memory _tokens = new address[][](count);
        uint256[][] memory _charges = new uint256[][](count);
        uint64 k = 0;
        for (uint64 i = 0; i < networks.length; i++) {
            if (bridges[networks[i]] != address(0)) {
                _networks[k] = networks[i];
                (_tokens[k], _charges[k]) = IBridge(bridges[networks[i]])
                    .charges();
                k++;
            }
        }
        info.ids = _networks;
        info.tokens = _tokens;
        info.charges = _charges;
    }

    function getTokenReq(
        uint64 futureBlock,
        address token,
        uint64[] memory futureBlocks,
        mapping(address => mapping(uint64 => TokenReq)) storage tokenReqs
    ) internal view returns (uint256 amount, uint256 percent) {
        TokenReq memory _req = getReq(
            futureBlock,
            token,
            futureBlocks,
            tokenReqs
        );
        amount = _req.minAmount;
        percent = _req.chargePercent;
    }

    function getCollectedChargesCN(
        ICrossBridgeStorageToken bridgeStorage,
        uint8 networkId
    ) internal view returns (TokensChargesInfo memory info) {
        uint8[] memory _networks = new uint8[](1);
        address[][] memory _tokens = new address[][](1);
        uint256[][] memory _charges = new uint256[][](1);
        _networks[0] = networkId;
        (_tokens[0], _charges[0]) = bridgeStorage.charges();
        info.ids = _networks;
        info.tokens = _tokens;
        info.charges = _charges;
    }

    function getTransactionInfo(
        uint64 futureBlock,
        address token,
        uint256 amount,
        uint64[] memory futureBlocks,
        mapping(address => mapping(uint64 => TokenReq)) storage tokenReqs
    ) internal view returns (uint256 fee, uint256 amountAfterCharge) {
        TokenReq memory _req = getReq(
            futureBlock,
            token,
            futureBlocks,
            tokenReqs
        );
        fee = (amount * _req.chargePercent) / CHARGE_PERCENTAGE_DIVIDER;
        amountAfterCharge = amount - fee;
    }

    function updateMap(
        address[] memory arr,
        bool status,
        mapping(address => bool) storage map
    ) internal {
        for (uint64 i = 0; i < arr.length; i++) {
            map[arr[i]] = status;
        }
    }

    function getReq(
        uint64 blockIndex,
        address token,
        uint64[] memory futureBlocks,
        mapping(address => mapping(uint64 => TokenReq)) storage tokenReqs
    ) internal view returns (TokenReq memory req) {
        req = tokenReqs[token][blockIndex];
        if (!req.exist) {
            for (uint256 i = futureBlocks.length; i > 0; i--) {
                if (futureBlocks[i - 1] <= blockIndex) {
                    req = tokenReqs[token][futureBlocks[i - 1]];
                    if (req.exist) return req;
                }
            }
        }
    }

    function getCountBySearchIndex(
        uint64 searchBlockIndex,
        address[] memory tokens,
        mapping(address => bool) storage mapTokens,
        mapping(address => uint64) storage mapTokenCreatedBlockIndex
    ) internal view returns (uint64 k) {
        for (uint64 i = 0; i < tokens.length; i++) {
            if (
                mapTokens[tokens[i]] &&
                (mapTokenCreatedBlockIndex[tokens[i]] <= searchBlockIndex)
            ) {
                k++;
            }
        }
    }
}

// File: contracts/BaseCrossBridge/interface/ICrossBridgeStorage.sol

pragma solidity ^0.8.7;

interface ICrossBridgeStorage {
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event SignersChanged(
        address[] indexed oldSigners,
        address[] indexed newSigners
    );

    event RelayersChanged(
        address[] indexed oldRelayers,
        address[] indexed newRelayers
    );

    function owner() external view returns (address);

    function admin() external view returns (address);

    function bridge() external view returns (address);

    function network() external view returns (NetworkInfo memory);

    function epoch() external view returns (uint64);

    function signers() external view returns (address[] memory);

    function relayers() external view returns (address[] memory);

    function mapSigner(address signer) external view returns (bool);

    function mapRelayer(address relayer) external view returns (bool);

    function setCallers(address admin, address bridge) external;

    function setEpoch(uint64 epoch) external;

    function setSigners(address[] memory signers_) external;

    function setRelayers(address[] memory relayers_) external;

    function signerVerification(
        bytes32 msgHash,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external view returns (bool);
}

// File: contracts/BaseCrossBridge/interface/ICrossBridge.sol

pragma solidity ^0.8.7;

interface ICrossBridge {
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    function owner() external view returns (address);

    function epoch() external view returns (uint64);

    function cap(address token) external view returns (uint256);

    function tokens(uint64 searchBlockIndex)
        external
        view
        returns (
            uint8[] memory networkIds,
            address[][] memory tokens,
            address[][] memory crossTokens,
            uint256[][] memory minAmounts,
            uint8[][] memory tokenTypes
        );

    function blockScanRange(uint8 networkId)
        external
        view
        returns (uint64[] memory);

    function processSigners(
        uint64 epoch,
        address[] memory signers,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external;

    function processPack(
        uint8 id,
        uint64[2] memory scanRange,
        uint256[] memory txHashes,
        address[] memory tokens,
        address[] memory recipients,
        uint256[] memory amounts,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external;

    function setSigners(address[] memory signers) external;

    function setRelayers(address[] memory relayers) external;

    function withdrawal(
        address token,
        address recipient,
        uint256 amount,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external;
}

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol

// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol

// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: contracts/BaseToken/interface/ITokenMintable.sol

pragma solidity ^0.8.7;

interface ITokenMintable is IERC20Upgradeable {
    function initialize(
        address factory,
        string memory name,
        string memory symbol,
        uint256 amount,
        uint256 cap
    ) external;

    function factory() external view returns (address);

    function cap() external view returns (uint256);

    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    function increaseCap(uint256 cap) external;
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol

// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data)
        private
    {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol

// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol

// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol

// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}

// File: contracts/BaseCrossBridge/base/CrossBridgeUpgradeable.sol

pragma solidity ^0.8.7;

contract CrossBridgeUpgradeable is
    Initializable,
    OwnableUpgradeable,
    ICrossBridge
{
    using SafeERC20Upgradeable for ITokenMintable;
    using BridgeSecurity for *;
    using BridgeUtils for *;
    using BridgeScanRange for uint64[];

    ITokenFactory private tf;
    ICrossBridgeStorage private bs;
    ICrossBridgeStorageToken private bts;

    address[] private _wdSigners;
    mapping(address => bool) private _mapWdSigners;

    modifier onlyRelayer() {
        require(bs.mapRelayer(msg.sender), "OR");
        _;
    }

    function __CrossBridge_init(
        address tokenFactory,
        address bridgeStorage,
        address bridgeTokenStorage,
        address[] memory wdSigners_
    ) internal initializer {
        __Ownable_init();
        tf = ITokenFactory(tokenFactory);
        bs = ICrossBridgeStorage(bridgeStorage);
        bts = ICrossBridgeStorageToken(bridgeTokenStorage);
        _wdSigners = wdSigners_;
        for (uint64 i = 0; i < wdSigners_.length; i++) {
            _mapWdSigners[wdSigners_[i]] = true;
        }
    }

    function owner()
        public
        view
        virtual
        override(OwnableUpgradeable, ICrossBridge)
        returns (address)
    {
        return super.owner();
    }

    function epoch() public view virtual override returns (uint64 epoch_) {
        epoch_ = bs.epoch();
    }

    function cap(address token) external view override returns (uint256 _cap) {
        return ITokenMintable(token).cap();
    }

    function blockScanRange(uint8 networkId)
        external
        view
        virtual
        override
        returns (uint64[] memory blockScanRange_)
    {
        NetworkInfo memory network = bs.network();
        if (networkId == network.id) blockScanRange_ = bts.blockScanRange();
    }

    function tokens(uint64 searchBlockIndex)
        external
        view
        virtual
        override
        returns (
            uint8[] memory networkIds,
            address[][] memory tokens_,
            address[][] memory crossTokens,
            uint256[][] memory minAmounts,
            uint8[][] memory tokenTypes
        )
    {
        uint64 futureBlock = searchBlockIndex.getFuture();
        (networkIds, tokens_, crossTokens, minAmounts, , tokenTypes) = bts
            .tokens(tf, futureBlock, searchBlockIndex);
    }

    function processSigners(
        uint64 epoch_,
        address[] memory signers_,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external virtual override onlyRelayer {
        require(epoch_ > epoch(), "IE");
        bytes32 msgHash = epoch_.generateSignerMsgHash(signers_);
        if (bs.signerVerification(msgHash, v, r, s)) {
            bs.setEpoch(epoch_);
            bs.setSigners(signers_);
        }
    }

    function processPack(
        uint8 networkId,
        uint64[2] memory blockScanRange_,
        uint256[] memory txHashes,
        address[] memory tokens_,
        address[] memory recipients,
        uint256[] memory amounts,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external virtual override onlyRelayer {
        require(blockScanRange_[1] > blockScanRange_[0], "IR");
        bytes32 msgHash = address(this).generatePackMsgHash(
            epoch(),
            networkId,
            blockScanRange_,
            txHashes,
            tokens_,
            recipients,
            amounts
        );

        if (bs.signerVerification(msgHash, v, r, s)) {
            uint64 futureBlock = block.number.getFuture();
            for (uint64 i = 0; i < txHashes.length; i++) {
                if (!bts.txHash(txHashes[i]) && bts.mapToken(tokens_[i])) {
                    bts.setTxHash(txHashes[i]);

                    (uint256 fee, uint256 amountAfterCharge) = bts
                        .transactionInfo(futureBlock, tokens_[i], amounts[i]);

                    if (tf.tokenExist(tokens_[i])) {
                        ITokenMintable(tokens_[i]).mint(
                            recipients[i],
                            amountAfterCharge
                        );
                    } else {
                        ITokenMintable(tokens_[i]).safeTransfer(
                            recipients[i],
                            amountAfterCharge
                        );
                    }
                    bts.setCollectedCharges(tokens_[i], fee);
                }
            }
            bts.setScanRange(blockScanRange_);
        }
    }

    function setSigners(address[] memory signers)
        external
        virtual
        override
        onlyOwner
    {
        bs.setSigners(signers);
    }

    function setRelayers(address[] memory relayers)
        external
        virtual
        override
        onlyOwner
    {
        bs.setRelayers(relayers);
    }

    function withdrawal(
        address token,
        address recipient,
        uint256 amount,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external virtual override onlyOwner {
        require(token != address(0), "ZA");
        require(recipient != address(0), "ZA");
        require(r.length == _wdSigners.length, "SG1");

        bytes32 msgHash = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                address(this),
                token,
                recipient,
                amount
            )
        );

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        msgHash = keccak256(abi.encodePacked(prefix, msgHash));

        uint64 verified = 0;
        address lastAddr = address(0);
        for (uint64 i = 0; i < _wdSigners.length; i++) {
            address recovered = ecrecover(msgHash, v[i], r[i], s[i]);
            require(recovered > lastAddr && _mapWdSigners[recovered], "SG2");
            lastAddr = recovered;
            verified++;
        }

        if (verified == _wdSigners.length) {
            ITokenMintable(token).safeTransfer(recipient, amount);
        }
    }
}

// File: contracts/Net-Ethereum/Bridge/EthereumBridge.sol

pragma solidity ^0.8.7;

contract EthereumBridge is CrossBridgeUpgradeable {
    function initialize(
        address tokenFactory,
        address bridgeStorage,
        address bridgeTokenStorage,
        address[] memory wdSigners
    ) public initializer {
        __CrossBridge_init(
            tokenFactory,
            bridgeStorage,
            bridgeTokenStorage,
            wdSigners
        );
    }
}