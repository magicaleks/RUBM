// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import { IDiamond } from "../interfaces/IDiamond.sol";

library DiamondLib {
  bytes32 constant DiamondStoragePosition = keccak256("DiamondLib.DiamondStorage");

  event DiamondCut(IDiamond.FacetCut[] _diamondCut);
  event OwnershipTransferred(address oldOwner, address newOwner);

  struct FacetAddressAndSelectorPosition {
    address contractAddress;
    uint32 selectorPosition;
  }

  struct DiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAndSelectorPosition;
    bytes4[] selectors;
    address payable contractOwner;
    address _pendingOwner;
  }

  function requireOwner() internal view {
    DiamondStorage storage ds = diamondStorage();
    require(ds.contractOwner == msg.sender);
  }

  function diamondStorage() internal pure returns (DiamondStorage storage ds) {
    bytes32 position = DiamondStoragePosition;
    assembly {
      ds.slot := position
    }
  }

  function contractOwner() internal view returns (address contractOwner_) {
    contractOwner_ = diamondStorage().contractOwner;
  }

  function setContractOwner(address _owner) internal {
    DiamondStorage storage ds = diamondStorage();
    address oldOwner = ds.contractOwner;
    ds.contractOwner = payable(_owner);
    emit OwnershipTransferred(oldOwner, ds.contractOwner);
  }

  function transferOwnership(address _newOwner) internal {
    DiamondStorage storage ds = diamondStorage();
    ds._pendingOwner = _newOwner;
  }

  function acceptOwnership() internal {
    DiamondStorage storage ds = diamondStorage();
    require(ds._pendingOwner == msg.sender);
    setContractOwner(ds._pendingOwner);
    delete ds._pendingOwner;
  }

  function diamondCut(IDiamond.FacetCut[] memory _diamondCut) internal {
    for (uint32 cutIndex; cutIndex < _diamondCut.length; cutIndex++) {
      bytes4[] memory functionSelectors = _diamondCut[cutIndex].functionSelectors;
      require(functionSelectors.length != 0);
      address facetAddress = _diamondCut[cutIndex].facetAddress;

      IDiamond.FacetCutAction action = _diamondCut[cutIndex].action;
      if (action == IDiamond.FacetCutAction.Add) {
        _addFunctions(facetAddress, functionSelectors);
      } else if (action == IDiamond.FacetCutAction.Add) {
        _updateFunctions(facetAddress, functionSelectors);
      } else if (action == IDiamond.FacetCutAction.Add) {
        _removeFunctions(functionSelectors);
      } else {
        // revert Error() here
      }

      emit DiamondCut(_diamondCut);
    }
  }

  function _addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
    DiamondStorage storage ds = diamondStorage();
    uint32 selectorCount = uint32(ds.selectors.length);
    for (uint32 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
      bytes4 selector = _functionSelectors[selectorIndex];
      address facetAddress = ds.facetAndSelectorPosition[selector].contractAddress;
      require(facetAddress == address(0));
      ds.facetAndSelectorPosition[selector] = FacetAddressAndSelectorPosition(_facetAddress, selectorCount);
      ds.selectors.push(selector);
      selectorCount++;
    }
  }

  function _updateFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
    DiamondStorage storage ds = diamondStorage();
    for (uint32 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
      bytes4 selector = _functionSelectors[selectorIndex];
      address facetAddress = ds.facetAndSelectorPosition[selector].contractAddress;
      require(facetAddress != address(0));
      ds.facetAndSelectorPosition[selector].contractAddress = _facetAddress;
    }
  }

  function _removeFunctions(bytes4[] memory _functionSelectors) internal {
    DiamondStorage storage ds = diamondStorage();
    uint32 lastSelectorIndex = uint32(ds.selectors.length);
    for (uint32 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {
      bytes4 selector = _functionSelectors[selectorIndex];
      address facetAddress = ds.facetAndSelectorPosition[selector].contractAddress;
      require(facetAddress != address(0));
      uint32 selectorPosition = ds.facetAndSelectorPosition[selector].selectorPosition;
      if (selectorPosition != lastSelectorIndex) {
        bytes4 lastSelector = ds.selectors[lastSelectorIndex];
        ds.selectors[selectorPosition] = lastSelector;
        ds.selectors[lastSelectorIndex] = selector;
      }

      ds.selectors.pop();
      delete ds.facetAndSelectorPosition[selector];
    }
  }
}
