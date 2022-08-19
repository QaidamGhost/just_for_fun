function p=Benford(total)
    count1=0;
    count2=0;
    count3=0;
    count4=0;
    count5=0;
    count6=0;
    count7=0;
    count8=0;
    count9=0;

    for i=1:total
        tmp=exp(normrnd(0,10));
        while(tmp>=10)
            tmp=tmp/10;
        end        
        while(tmp<1)
            tmp=tmp*10;
        end

        if tmp<2
            count1=count1+1;
        end
        if tmp<3&&tmp>=2
            count2=count2+1;
        end
        if tmp<4&&tmp>=3
            count3=count3+1;
        end
        if tmp<5&&tmp>=4
            count4=count4+1;
        end
        if tmp<6&&tmp>=5
            count5=count5+1;
        end
        if tmp<7&&tmp>=6
            count6=count6+1;
        end     
        if tmp<8&&tmp>=7
            count7=count7+1;
        end
        if tmp<9&&tmp>=8
            count8=count8+1;
        end
        if tmp>=9
            count9=count9+1;
        end        
    end
    p.p1=count1/total*100;
    p.p2=count2/total*100;
    p.p3=count3/total*100;
    p.p4=count4/total*100;
    p.p5=count5/total*100;
    p.p6=count6/total*100;
    p.p7=count7/total*100;
    p.p8=count8/total*100;
    p.p9=count9/total*100;    
end