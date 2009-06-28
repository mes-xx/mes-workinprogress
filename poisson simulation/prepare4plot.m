for x = 1:50
    for y = x:50
        
        temp = mins{x,y};
        
        z(x,y) = temp(end);
        z(y,x) = temp(end);
        
    end
end