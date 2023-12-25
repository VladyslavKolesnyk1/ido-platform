import { network } from "hardhat";

type Config = {
  TICKET_PRICE: string;
  MIN_TICKETS: string;
  MAX_TICKETS: string;
  START_TIME: number | string;
  END_TIME: number | string;
  SHARE_PER_TICKET: string;
  PURCHASE_TOKEN_ADDRESS: string;
  IDO_TOKEN_ADDRESS: string;
  OWNER: string;
  // it's used in IDO contract because it may have multiple purchase tokens
  PURCHASE_TOKENS: string[];
  DATA_FEEDS: string[];
  VESTING_PERCENTS: number[];
  CLIFF_DURATION: number | string;
  TOKEN_PRICE: string;
  SOFT_CAP: string;
  MAX_CAP: string;
  MAX_ALLOCATION: string;
  MIN_ALLOCATION: string;
};

const LOCAL_CONFIG = {
  TICKET_PRICE: "0",
  MIN_TICKETS: "1",
  MAX_TICKETS: "5",
  START_TIME: 1703527200,
  END_TIME: 1703959200,
  SHARE_PER_TICKET: "10000000000",
  PURCHASE_TOKEN_ADDRESS: "0x",
  IDO_TOKEN_ADDRESS: "0x",
  OWNER: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  PURCHASE_TOKENS: [],
  DATA_FEEDS: ["0x3e7d1eab13ad0104d2750b8863b489d65364e32d"], // USDT/USD eth price feed
  VESTING_PERCENTS: [100], // 100% right after the end of IDO cliff
  CLIFF_DURATION: 0,
  TOKEN_PRICE: "100000",
  SOFT_CAP: "1000000000000",
  MAX_CAP: "1000000000000",
  MAX_ALLOCATION: "1000000000",
  MIN_ALLOCATION: "10000000",
};

const TESTNET_CONFIG = {
  TICKET_PRICE: "0",
  MIN_TICKETS: "0",
  MAX_TICKETS: "0",
  START_TIME: "0",
  END_TIME: "0",
  SHARE_PER_TICKET: "0",
  PURCHASE_TOKEN_ADDRESS: "0x",
  IDO_TOKEN_ADDRESS: "0x",
  OWNER: "0x",
  PURCHASE_TOKENS: [],
  DATA_FEEDS: [],
  VESTING_PERCENTS: [],
  CLIFF_DURATION: "0",
  TOKEN_PRICE: "0",
  SOFT_CAP: "0",
  MAX_CAP: "0",
  MAX_ALLOCATION: "0",
  MIN_ALLOCATION: "0",
};

const MAINNET_CONFIG = {
  TICKET_PRICE: "0",
  MIN_TICKETS: "0",
  MAX_TICKETS: "0",
  START_TIME: "0",
  END_TIME: "0",
  SHARE_PER_TICKET: "0",
  PURCHASE_TOKEN_ADDRESS: "0x",
  IDO_TOKEN_ADDRESS: "0x",
  OWNER: "0x",
  PURCHASE_TOKENS: [],
  DATA_FEEDS: [],
  VESTING_PERCENTS: [],
  CLIFF_DURATION: "0",
  TOKEN_PRICE: "0",
  SOFT_CAP: "0",
  MAX_CAP: "0",
  MAX_ALLOCATION: "0",
  MIN_ALLOCATION: "0",
};

export const CONFIG: Config =
  network.name === "localhost" ? LOCAL_CONFIG : network.name === "mainnet" ? MAINNET_CONFIG : TESTNET_CONFIG;
