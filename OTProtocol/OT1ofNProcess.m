function m_b = OT1ofNProcess(m,b)

PA = PartA1ofN(m);
PB = PartB1ofN(b, PA.getL());

for m = 1:PA.getL()
    KVal(m) = OT1of2Process(PA.K(:,m), PB.BitsOfB(m));
end
PB = PB.setKVal(KVal);

PB = PB.receiveYsFromA(PA.sendYs2PartB());

m_b = PB.getMb();

end