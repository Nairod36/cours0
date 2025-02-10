"use client";
import React from "react";
import { useAccount, useConnect } from "@starknet-react/core";
import useGetData from "./hooks/useCounterValue";

export default function HomePage() {
  const { address, status } = useAccount();
  const { connect, connectors } = useConnect();

  // Lecture du contrat via notre hook
  const { counterBalance, counterRefetch, fetchStatus } = useGetData();

  return (
    <main>
      <h1>Ma DApp</h1>

      {status === "connected" ? (
        <>
          <p>Connecté avec l’adresse : {address}</p>
          {/* Exemple : afficher le résultat du contrat */}
          <p>fetchStatus : {fetchStatus}</p>
          <p>
            counterBalance :{" "}
            {JSON.stringify(counterBalance, (key, value) =>
              typeof value === "bigint" ? value.toString() : value
            )}
          </p>{" "}
          <button onClick={() => counterRefetch?.()}>Refetch</button>
        </>
      ) : (
        <div>
          <p>Pas de wallet connecté</p>
          {connectors.map((connector) => (
            <button
              key={connector.id}
              onClick={() => connect({ connector })}
              style={{ marginRight: 10 }}
            >
              Se connecter avec {connector.id}
            </button>
          ))}
        </div>
      )}
    </main>
  );
}
