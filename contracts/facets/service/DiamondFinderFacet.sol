// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import { IDiamondFinder } from "../../interfaces/IDiamondFinder.sol";
import { DiamondLib } from "../../libraries/DiamondLib.sol";

contract DiamondFinderFacet is IDiamondFinder {
  function findFacets() external view override returns(Facet[] memory _facets) {
    DiamondLib.DiamondStorage storage ds = DiamondLib.diamondStorage();
    uint32 selectorCount = uint32(ds.selectors.length);
    uint32 facetsNum = 0;
    uint8[] memory facetSelectorNum = new uint8[](selectorCount);
    _facets = new Facet[](facetsNum);

    bool continueLoop = false;
    for (uint32 selectorIndex; selectorIndex < selectorCount; selectorIndex++) {
      bytes4 _selector = ds.selectors[selectorIndex];
      address _facetAddress = ds.facetAndSelectorPosition[_selector].contractAddress;
      for (uint32 facetIndex; facetIndex < facetsNum; facetIndex++) {
        if (_facets[facetIndex].contractAddress == _facetAddress) {
          continueLoop = true;
          _facets[facetIndex].functionSelectors[facetSelectorNum[facetIndex]] = _selector;
          facetSelectorNum[facetIndex]++;
          break;
        }
      }

      if (continueLoop) {
        continueLoop = false;
        continue;
      }

      _facets[facetsNum].contractAddress = _facetAddress;
      _facets[facetsNum].functionSelectors = new bytes4[](selectorCount);
      _facets[facetsNum].functionSelectors[0] = _selector;
      facetSelectorNum[facetsNum] = 1;
      facetsNum++;
    }

    for (uint32 facetIndex; facetIndex < facetsNum; facetIndex++) {
      bytes4[] memory selectors = _facets[facetIndex].functionSelectors;
      uint8 selectorsNum = facetSelectorNum[facetIndex];
      assembly {
        mstore(selectors, selectorsNum)
      }
    }

    assembly {
        mstore(_facets, facetsNum)
    }
  }

  function findSelectors(address _facet) external view override returns(bytes4[] memory _facetSelectors) {
    DiamondLib.DiamondStorage storage ds = DiamondLib.diamondStorage();
    uint32 selectorCount = uint32(ds.selectors.length);
    uint32 selectorsNum = 0;
    _facetSelectors = new bytes4[](selectorCount);

    for (uint32 selectorIndex; selectorIndex < selectorCount; selectorIndex++) {
      bytes4 _selector = ds.selectors[selectorIndex];
      address _facetAddress = ds.facetAndSelectorPosition[_selector].contractAddress;
      if (_facetAddress == _facet) {
        _facetSelectors[selectorsNum] = _selector;
        selectorsNum++;
      }
    }

    assembly {
      mstore(_facetSelectors, selectorsNum)
    }
  }

  function findAddresses() external view override returns(address[] memory _facetAddresses) {
    DiamondLib.DiamondStorage storage ds = DiamondLib.diamondStorage();
    uint32 selectorCount = uint32(ds.selectors.length);
    uint32 addressesNum = 0;
    _facetAddresses = new address[](selectorCount);
    bool continueLoop = false;
    for (uint32 selectorIndex; selectorIndex < selectorCount; selectorIndex++) {
      bytes4 _selector = ds.selectors[selectorIndex];
      address _facetAddress = ds.facetAndSelectorPosition[_selector].contractAddress;
      for (uint32 addressIndex; addressIndex < addressesNum; addressIndex++) {
        if (_facetAddresses[addressIndex] == _facetAddress) {
          continueLoop = true;
          break;
        }
      }

      if (continueLoop) {
        continueLoop = false;
        continue;
      }

      _facetAddresses[addressesNum] = _facetAddress;
      addressesNum++;
    }

    assembly {
      mstore(_facetAddresses, addressesNum)
    }
  }

  function findSelectorFacetAddress(bytes4 _selector) external view override returns(address) {
    DiamondLib.DiamondStorage storage ds = DiamondLib.diamondStorage();
    return ds.facetAndSelectorPosition[_selector].contractAddress;
  }
}
