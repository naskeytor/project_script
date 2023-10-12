
import csv

# Specify the input and output file paths
input_file = 'Air_Traffic_Passenger_Statistics.csv'
output_file = 'Air_Traffic_Passenger_Statistics_with_ID.csv'

# Open the input and output files
with open(input_file, 'r') as csv_input, open(output_file, 'w', newline='') as csv_output:
    reader = csv.reader(csv_input)
    writer = csv.writer(csv_output)

    # Read the header row
    header = next(reader)
    header.insert(0, 'id')  # Add 'id' column to the header

    # Write the modified header to the output file
    writer.writerow(header)

    # Initialize the ID counter
    id_counter = 1

    # Process each row in the input file
    for row in reader:
        row.insert(0, id_counter)  # Add the ID value at the beginning of each row
        writer.writerow(row)

        id_counter += 1  # Increment the ID counter for the next row

print("ID column added successfully!")


