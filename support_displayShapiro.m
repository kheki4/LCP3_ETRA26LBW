function support_displayShapiro(vec)
    [H, pValue, W] = support_swtest(vec);
    if pValue < 0.05
        disp(['Variable does not follow a normal distribution according to the Shapiro-Wilk test. p = ' num2str(pValue)]);
    else
        disp(['Variable follows a normal distribution according to the Shapiro-Wilk test. p = ' num2str(pValue)]);
    end
end