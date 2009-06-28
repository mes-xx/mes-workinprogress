function z = mes_prepare_plot1( cell_array )
% mes_prepare_plot1( cell_array )
% For each cell in cell_array, takes the last element of the matrix in that
% cell and puts the value in a normal array, to be plotted. Also, copies
% values from the upper part of the matrix across the main diagonal

for row = 1:size(cell_array, 1)
    for col = row:size(cell_array, 2)
        
        temp = cell_array{row,col};
        
        z(row,col) = temp(end);
        z(col,row) = temp(end);
        
    end
end