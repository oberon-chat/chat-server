const formatTimestamp = (timestamp) => {
  const date = new Date(timestamp)

  return date.toLocaleTimeString()
}

export default formatTimestamp
