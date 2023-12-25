import { network } from "hardhat";

type Config = {
  TICKET_PRICE: string;
  MIN_TICKETS: string;
  MAX_TICKETS: string;
  START_TIME: string;
  END_TIME: string;
  SHARE_PER_TICKET: string;
  PURCHASE_TOKEN_ADDRESS: string;
  IDO_TOKEN_ADDRESS: string;
  OWNER: string;
  // it's used in IDO contract because it may have multiple purchase tokens
  PURCHASE_TOKENS: string[];
  DATA_FEEDS: string[];
  VESTING_PERCENTS: string[];
  CLIFF_DURATION: string;
  TOKEN_PRICE: string;
  SOFT_CAP: string;
  MAX_CAP: string;
  MAX_ALLOCATION: string;
  MIN_ALLOCATION: string;
};

const LOCAL_CONFIG = {
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
