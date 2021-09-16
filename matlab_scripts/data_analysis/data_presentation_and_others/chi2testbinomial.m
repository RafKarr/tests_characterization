function [h,chi2stat,pvalue,df] = chi2testbinomial(realDist,p,isPEstimated,significance)
%CHI2TESTBINOMIAL Do the chi squared test for binomial distribution

if (isPEstimated == "yes")
    df = length(realDist)-2;
else
    if (isPEstimated == "no")
        df = length(realDist)-1;
    else
        e = MException('chi2testbinomial','Wrong specification of estimation of P');
        throw(e);
    end
end

 if ~exist('significance','var')
     % third parameter does not exist, so default it to something
      significance = 0.05;
 end

%Get estimated distribution
bins = 0 : length(realDist)-1;
pd = makedist("Binomial","N",length(realDist)-1,"p",p);
expectedDist = length(realDist) * pdf(pd,bins);

%Calculate the statistic
chi2stat = ((realDist - expectedDist).^2)./expectedDist;
chi2stat = sum(chi2stat);

pvalue = chi2cdf(chi2stat,df,'upper');

if pvalue < significance
    h = 1;
else
    h = 0;
end

end

