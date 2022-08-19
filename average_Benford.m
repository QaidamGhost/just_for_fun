function p_mu=average_Benford(total)
tic
    attempts=1E3;
    p1=zeros(1,attempts);
    p2=zeros(1,attempts);
    p3=zeros(1,attempts);
    p4=zeros(1,attempts);
    p5=zeros(1,attempts);
    p6=zeros(1,attempts);
    p7=zeros(1,attempts);
    p8=zeros(1,attempts);
    p9=zeros(1,attempts);

    for i=1:attempts
        p=Benford(total);
        p1(i)=p.p1;
        p2(i)=p.p2;
        p3(i)=p.p3;
        p4(i)=p.p4;
        p5(i)=p.p5;
        p6(i)=p.p6;
        p7(i)=p.p7;
        p8(i)=p.p8;        
        p9(i)=p.p9;
    end
    p_mu.p1=mean(p1);
    p_mu.p2=mean(p2);
    p_mu.p3=mean(p3);
    p_mu.p4=mean(p4);
    p_mu.p5=mean(p5);
    p_mu.p6=mean(p6);
    p_mu.p7=mean(p7);
    p_mu.p8=mean(p8);
    p_mu.p9=mean(p9);

toc    
end