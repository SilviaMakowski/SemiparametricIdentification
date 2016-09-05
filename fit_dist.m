%fitting semiparametric distribution
function[fnpoints] =fit_dist(data_pts, area_pts, alpha, sigma2, iter_no, iter_burnin_no, rang)
	rng(1); %setting the seed to get consistent result each run

	data_pts=data_pts';
	area_pts=area_pts';
	ad=[data_pts,area_pts]; %whole set of points (training testing gaussian_quadrature)


	dp=fitdist(data_pts','gamma'); %gamma distribution fitted to the training data
	dprob=pdf(dp,data_pts); %most fitted gamma distribution to the data points

	%create the covariance matrix
	c=cov(ad,alpha, sigma2);

	dindex=1:size(data_pts,2); %indexes of the data points in ad
	xindex=size(data_pts,2)+1:(size(data_pts,2)+size(area_pts,2)); %indexes of the area points in as


	dlikelihood=sum(log(dprob)); %likelihood of the data points using dprob
	startsampling=iter_no-iter_burnin_no;

	smple=mvnrnd(zeros(length(ad),1),c,iter_no);


	%intiale distribution
	pt=sum(log(pdf(dp,data_pts)));
	wholesample=zeros(1,size(ad,2));
	
	fnpoints = zeros(1,size(ad,2));
	
	vrtn=0;
	cdpr=dp;
	dpr=dp;
	xprobr=pdf(cdpr,area_pts);
	xlikelihoodr=log(xprobr);
	totaldpa=0;
	totaldpb=0;
	
	indexmat=-inf(size(rang,1),length(area_pts));
	firstmat=ones(1,size(rang,1));
	lastmat=ones(1,size(rang,1));

    %precalculate area parameters 
	rang_size=size(rang,1);
	if rang_size>1
		range=rang(:,2)-rang(:,1);
		for i=1:size(rang,1)
			
			ind{i}=find(area_pts>=rang(i,1) & area_pts<=rang(i,2));
			indexmat(i,ind{i})=0;
			rat(i)=(range(i)/(2*length(ind{i})));
			firstmat(i)=sub2ind(size(indexmat),i,ind{i}(1));
			lastmat(i)=sub2ind(size(indexmat),i,ind{i}(end));
		end
	else
		mrat=(max(area_pts)-min(area_pts))/(2*length(area_pts));
		mmat=[1;(2*ones(length(xindex)-2,1));1];
		mdlen=length(data_pts);
    end

    %sampling
	for iter=1:iter_no 
		fn=smple(iter,:);

		if rang_size<2 %calculate the area if range isn't considered
			area = repmat(mrat*(exp(xlikelihoodr+fn(xindex))*mmat),mdlen,1);
			
        else %else calculate the area considering the range
			likemat=repmat(xlikelihoodr,size(rang,1),1)+indexmat;
			fnmat=repmat(fn(xindex), size(rang,1),1)+indexmat;
			expmat=exp(likemat+fnmat);
			area=((2*sum(expmat,2))'-expmat(firstmat)-expmat(lastmat)).*rat;
		end
		pt1=dlikelihood+sum(fn(dindex))-sum(log(area));
		A=pt1 - pt;

		if log(rand) < A %acceptance/rejection of a sample
			cdpr=dpr;
			wholesample=fn;
			pt=pt1;
        end
		
        %sampling a new fitted gamma distribution
		randa=mvnrnd(cdpr.a,(vrtn*dp.a));
		randb=mvnrnd(cdpr.b,(vrtn*dp.b));
		while randa <= 0 
			randa=mvnrnd(cdpr.a,(vrtn*dp.a));
		end
		while randb <= 0
			randb=mvnrnd(cdpr.b,(vrtn*dp.b));
		end
		dpr = makedist('Gamma','a',randa,'b',randb);
		xprobr=pdf(dpr,area_pts);
		xlikelihoodr=log(xprobr);
		dprob=pdf(dpr,data_pts);
		dlikelihood=sum(log(dprob));
		
		if iter > startsampling %if the iterations are in the burnin phase

			 totaldpa=totaldpa+cdpr.a;
			 totaldpb=totaldpb+cdpr.b;
			 
			 dpc = makedist('Gamma','a',cdpr.a,'b',cdpr.b);
			 finalarea = myNewtonCotes(exp(log(pdf(dpc,area_pts))+wholesample(xindex)),area_pts);
			 fnpoints=fnpoints+(exp([log(pdf(dpc,data_pts)) log(pdf(dpc,area_pts))]+wholesample)/finalarea);

		end      
	end

	fnpoints=fnpoints./iter_burnin_no;
	fnpoints=fnpoints(xindex);
end

%calculating the covariance 
function[c] = cov(array, alpha, sigma2)
    c=zeros(length(array));
    for i=1:1:size(array,2)
		c(i,i)=alpha;
		for j=i+1:1:size(array,2)
			c(i,j)=alpha*exp(((array(i)-array(j))^2)/(-2*(sigma2^2)));
			c(j,i)=c(i,j);
		end
    end
end