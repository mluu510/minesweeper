while true
  puts "Select a piece to move"
  input = gets.split('')
  col = input[0].ord-97
  row = (input[1].to_i-8).abs
  pos = [row, col]
  p pos
end