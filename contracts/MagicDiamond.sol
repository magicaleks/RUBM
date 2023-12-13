// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { DiamondLib } from "./libraries/DiamondLib.sol";
import { IDiamond } from "./interfaces/IDiamond.sol";

contract MagicDiamond {

  struct InitArgs {
    address owner;
  }

  error FunctionNotFound(bytes4 _funtionSelector);

  constructor(IDiamond.FacetCut[] memory _diamondCut, InitArgs memory _args) {
    DiamondLib.setContractOwner(_args.owner);
    DiamondLib.diamondCut(_diamondCut);
  }

  fallback() external payable {
    DiamondLib.DiamondStorage storage ds = DiamondLib.diamondStorage();
    address facetAddress = ds.facetAndSelectorPosition[msg.sig].contractAddress;
    require(facetAddress != address(0));
    assembly {
      calldatacopy(0, 0, calldatasize())
      let result := delegatecall(gas(), facetAddress, 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
          case 0 {
              revert(0, returndatasize())
          }
          default {
              return(0, returndatasize())
          }
        }
  }

  receive() external payable {}
}
