import Web3 from "web3";
import { ethers } from "ethers";
import DAOFactory from "../contracts/DAOFactory.json";
// import ForexTrade from "../contracts/ForexTrade.json";


let web3;

if (window.ethereum) {
  web3 = new Web3(window.ethereum);
}

export const DAO_FACTORY_ADDRESS =
  "0x98dbfD1b189E84eC81b54B17057533efFa86c334"; // ropsten

/* DAOFactory Contract */
export async function DAOFactoryContract() {
  return await new web3.eth.Contract(
    DAOFactory.abi,
    DAO_FACTORY_ADDRESS
  );
}

export async function DAOFactoryContractEthers() {
  let provider = ethers.getDefaultProvider("ropsten");
  let contract = new ethers.Contract(
    DAO_FACTORY_ADDRESS,
    DAOFactory.abi,
    provider
  );
  return contract;
}

export async function createDAO(entryFeeInEth, votingPeriod) {
  const contr = await DAOFactoryContract();

  const entryFeeWei = web3.utils.toWei(entryFeeInEth, "ether");
  await contr.methods.createDAO(entryFeeWei, votingPeriod).send({
    from: web3.eth.accounts.givenProvider.selectedAddress,
    value: entryFeeWei
  });
}

export async function getDAOsByAddress(address) {
  const contr = await DAOFactoryContract();
  const resp = await contr.methods.getUserDAOs(address).call();
  console.log(resp)
  return resp;
}

export async function getUsersByDAO(address) {
  const contr = await DAOFactoryContract();
  const resp = await contr.methods.getDAOUsers(address).call();
  console.log(resp)
  return resp;
}



// export async function getPastTradeEvents(address) {
//   const contr = await FTFContract();
//   const tradeCreatedLogs = await contr.getPastEvents(
//     "TradeCreated",
//     { creator: address },
//     { fromBlock: 0, toBlock: "latest" }
//   );
//   console.log("tradecreatedlogs", tradeCreatedLogs);
// }
