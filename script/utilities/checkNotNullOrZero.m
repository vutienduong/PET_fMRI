function k = checkNotNullOrZero( val )
  if isempty(val) || val == 0
        k = 0;
    else
        k = 1;
  end