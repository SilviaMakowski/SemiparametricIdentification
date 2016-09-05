%calculate the likelihood of data points on the distribution function 
function[f] =data_lik(data_pts, area_pts, funct_pts, rang )
rng(1); % setting the seed to get consistent result
if length(data_pts)<1 % in case there was no data points then likelihood is 0
    f=0;
    return;
end

data_pts=data_pts';
area_pts=area_pts';

uagb=interp1(area_pts,funct_pts,data_pts); %getting the data points likelihood/values from the distribution
uagb(isnan(uagb)) = 0.000000000001;

rang_size=size(rang,1);
if rang_size>1 %normalize the likelihood according to the range
    for i=1:rang_size
        ind=find(area_pts>=rang(i,1) & area_pts<=rang(i,2));
        ara(i)=((rang(i,2)-rang(i,1))/(2*length(ind)))*(funct_pts(ind)*[1;(2*ones(length(ind)-2,1));1]);
    end
else
    ara=myNewtonCotes(funct_pts,area_pts); %normalize the likelihood according the the area
end

f=sum(log(uagb))-sum(log(ara)); %normalized likelihood

