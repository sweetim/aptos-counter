import { Badge, Button, Flex, Typography } from "antd"
import { CSSProperties, FC, useEffect, useState } from "react"
import { MinusOutlined, PlusOutlined } from "@ant-design/icons"
import { useWallet } from "@aptos-labs/wallet-adapter-react"

import { decrementTransactionData, getNextFibonacciValue, incrementTransactionData, randomTransactionData } from "../contract"
import { getAptosClient } from "@/common/aptosClient"

const { Title, Text } = Typography

const aptos = getAptosClient()

const actionButtonStyle: CSSProperties = {
  width: "48px",
  height: "48px"
}

const actionIconStyle: CSSProperties = {
  fontSize: "32px",
  color: "#FFF"
}
export type ActionCounterProps = {
  value: string
}

const ActionCounter: FC<ActionCounterProps> = ({ value }) => {
  const { signAndSubmitTransaction, account } = useWallet()

  const [nextFibonacciValue, setNextFibonacciValue] = useState("...")

  useEffect(() => {
    getNextFibonacciValue().then(v => setNextFibonacciValue(v.toString()))
  }, [value])

  async function incrementClickHandler() {
    if (!account) return;

    try {
      const response: any = await signAndSubmitTransaction(incrementTransactionData())
      await aptos.waitForTransaction({ transactionHash: response.hash })
    } catch (error) {
      console.log(error)
    }
  }

  async function decrementClickHandler() {
    if (!account) return;

    try {
      const response: any = await signAndSubmitTransaction(decrementTransactionData())
      await aptos.waitForTransaction({ transactionHash: response.hash })
    } catch (error) {
      console.log(error)
    }
  }

  async function randomClickHandler() {
    if (!account) return;

    try {
      const response: any = await signAndSubmitTransaction(randomTransactionData())
      await aptos.waitForTransaction({ transactionHash: response.hash })
    } catch (error) {
      console.log(error)
    }
  }

  const countLeftToMint = Math.abs(Number(nextFibonacciValue) - Number(value))

  return (
    <Flex
      justify="center"
      align="center"
      gap="small"
      vertical
      style={{ height: "100%", width: "100%" }}>
      {account && <Button type="text"
        style={actionButtonStyle}
        icon={<PlusOutlined
          style={actionIconStyle} />}
        shape="circle"
        onClick={incrementClickHandler} />}
      <Title style={{ fontSize: "8rem", margin: 0, cursor: `${account ? "pointer" : "default"}` }}
        onClick={randomClickHandler}>{value}</Title>
      {account && <Button type="text"
        style={actionButtonStyle}
        icon={<MinusOutlined
          style={actionIconStyle} />}
        shape="circle"
        onClick={decrementClickHandler} />}
        <Text><Badge style={{color: "white", marginRight: "5px" }} count={countLeftToMint} overflowCount={100000} />count left to mint a fibonacci NFT</Text>
    </Flex>
  )
}

export default ActionCounter
