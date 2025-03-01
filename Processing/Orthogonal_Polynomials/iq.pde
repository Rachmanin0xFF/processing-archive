float Pgn(int l, int m, float x)
{
    float p0 = 0., p1 = 0., p2 = 0.;
    
    for (int k = l; k >= 0; k--)
  {
    float k1 = float(k + 1);
    float m1 = float(2 * m) + k1;
        float m2 = float(2 * (m + k) + 1);
        
    p2 = p1;
        p1 = p0;
        
    p0 = 0.;
        if (l == m + k)
            p0 = 1.;
        
        float u0 = sqrt(
      (m2 * (m2 + 2.0)) /
      (k1 * m1)
    );
        
        float u1 = sqrt(
            (k1 * m1 * (m2 + 4.0)) / 
      ((k1 + 1.0) * (m1 + 1.0) * m2)
        );
        
        p0 += p1 * u0 * x;
        p0 -= u1 * p2;
  }

    for (int k = 1; k <= m; k++)
  {
    p0 *= sqrt(
            (1.0 - 0.5/float(k)) * (1.0 - x) * (1.0 + x)
        );
  }
    
    p0 *= sqrt((0.5 * float(m) + 0.25)/PI);
    
    return p0;
}
