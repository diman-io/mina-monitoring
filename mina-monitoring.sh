status=$(docker exec mina_daemon_1 mina client status --json)

key=$(hostname)
now=$(date +%s%N)

blockchain_length=-1
high_block=-1
block_lag=0
peers=-1
uptime=0
sync_status=\"None\"
next_block_act=\"None\"
next_block_time=0

isJSON=$(echo $status | head -1 | cut -c -1)

if [ "$isJSON" == "{" ]; then
  blockchain_length=$(jq -c '.blockchain_length' <<<$status)
  high_block=$(jq -c '.highest_block_length_received' <<<$status)
  if [ $blockchain_length == "null" ]; then
    blockchain_length=0
  else
    block_lag=$(jq -c '.blockchain_length - .highest_block_length_received' <<<$status)
  fi
  peers=$(jq -c '.peers | length' <<<$status)
  uptime=$(jq -c '.uptime_secs' <<<$status)
  sync_status=$(jq -c '.sync_status' <<<$status)
  next_block_act=$(jq -c '.next_block_production | .timing | .[0]' <<<$status)
  if [ "$next_block_act" == "null" ]; then
    next_block_act=\"Null\"
  elif [ "$next_block_act" == "\"Produce\"" ]; then
    next_block_time=$(jq -c '.next_block_production | .timing | .[1] | .time | tonumber' <<<$status)
  fi
fi

echo mina,key=$key status=$sync_status,blockchain_length=$blockchain_length,high_block=$high_block,block_lag=$block_lag,peers=$peers,uptime=$uptime,next_block_act=$next_block_act,next_block_time=$next_block_time $now
