
import csv

input_file = 'Air_Traffic_Passenger_Statistics.csv'
output_file = 'Air_Traffic_Passenger_Statistics_with_ID.csv'

with open(input_file, 'r') as csv_input, open(output_file, 'w', newline='') as csv_output:
    reader = csv.reader(csv_input)
    writer = csv.writer(csv_output)

    header = next(reader)
    header.insert(0, 'id')
    writer.writerow(header)
    id_counter = 1

    for row in reader:
        row.insert(0, id_counter)  
        writer.writerow(row)
        id_counter += 1 


