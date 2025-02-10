"use client";

import { useAccount, useCall } from "@starknet-react/core";
import abi from "../../../abi.json";

// Adresse de déploiement de ton contrat
const CONTRACT_ADDRESS = "0x03957e2dbcfc1ef43f890e1fdf5b660821355b7ca01a68cb4a6aeac2238e4117";

export default function useGetData() {
  // Récupère l'adresse de l'utilisateur connecté
  const { address } = useAccount();

  // Appelle le contrat pour lire la valeur
  const { data: counterBalance, refetch: counterRefetch, fetchStatus } = useCall({
    address: CONTRACT_ADDRESS,
    abi: abi.abi,
    functionName: "get_value",
    args: address ? [address] : [],
    watch: true,
  });

  // Renvoie ce dont tu as besoin
  return {
    counterBalance,
    counterRefetch,
    fetchStatus,
  };
}