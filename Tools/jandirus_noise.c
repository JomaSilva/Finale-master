/*
 * jandirus_noise.c -- DLL de terreno procedural (chamada via call_ext do BYOND).
 * Compilar (32-bit, OBRIGATORIO -- o dd.exe e x86):  compilar-dll.bat
 *   zig cc -target x86-windows-gnu -shared -O2 -o jandirus_noise.dll Tools\jandirus_noise.c
 *
 * Export: surface_map(seed, size, h_water, h_beach, h_hill, h_mountain)
 *   Gera o mapa CLASSIFICADO do planeta inteiro numa chamada so:
 *   retorna size*size chars (ordem: coluna xx, depois yy — casa com o loop do DM),
 *   'W' agua, 'B' praia, 'P' planicie, 'H' colina, 'M' montanha.
 * Noise: value-noise fBm de 4 oitavas via hash inteiro (deterministico da seed).
 */
#include <stdlib.h>
#include <string.h>
#include <math.h>

static char  *outbuf = NULL;
static size_t outcap = 0;

static unsigned int hash2(int x, int y, unsigned int seed)
{
    unsigned int h = (unsigned int)x * 374761393u + (unsigned int)y * 668265263u + seed * 2246822519u;
    h ^= h >> 13;
    h *= 1274126177u;
    return h ^ (h >> 16);
}

static double vnoise(double x, double y, unsigned int seed)
{
    int    gx = (int)floor(x), gy = (int)floor(y);
    double fx = x - gx, fy = y - gy;
    fx = fx * fx * (3.0 - 2.0 * fx); /* smoothstep */
    fy = fy * fy * (3.0 - 2.0 * fy);
    double v00 = (hash2(gx,     gy,     seed) & 0xFFFF) / 65535.0;
    double v10 = (hash2(gx + 1, gy,     seed) & 0xFFFF) / 65535.0;
    double v01 = (hash2(gx,     gy + 1, seed) & 0xFFFF) / 65535.0;
    double v11 = (hash2(gx + 1, gy + 1, seed) & 0xFFFF) / 65535.0;
    double a = v00 + (v10 - v00) * fx;
    double b = v01 + (v11 - v01) * fx;
    return a + (b - a) * fy;
}

static double fbm(double x, double y, unsigned int seed)
{
    double v = 0.0, amp = 0.5, freq = 1.0 / 48.0, tot = 0.0;
    int    o;
    for (o = 0; o < 4; o++) {
        v   += vnoise(x * freq, y * freq, seed + (unsigned int)o * 101u) * amp;
        tot += amp;
        amp *= 0.5;
        freq *= 2.0;
    }
    v /= tot;
    /* fBm comprime a variancia pro meio (montanha/agua quase sumiam): estica o contraste */
    v = 0.5 + (v - 0.5) * 2.2;
    if (v < 0.0) v = 0.0;
    if (v > 1.0) v = 1.0;
    return v;
}

__declspec(dllexport) char *surface_map(int argc, char *argv[])
{
    unsigned int seed;
    int          size, xx, yy;
    double       hw, hb, hh, hm;
    if (argc < 6) return "ERR:args";
    seed = (unsigned int)strtoul(argv[0], NULL, 10);
    size = atoi(argv[1]);
    hw = atof(argv[2]);
    hb = atof(argv[3]);
    hh = atof(argv[4]);
    hm = atof(argv[5]);
    if (size < 3 || size > 2000) return "ERR:size";
    {
        size_t need = (size_t)size * (size_t)size + 1;
        if (outcap < need) {
            char *nb = (char *)realloc(outbuf, need);
            if (!nb) return "ERR:mem";
            outbuf = nb;
            outcap = need;
        }
    }
    for (xx = 0; xx < size; xx++) {
        for (yy = 0; yy < size; yy++) {
            double h = fbm((double)xx, (double)yy, seed);
            char   c;
            if      (h < hw) c = 'W';
            else if (h < hb) c = 'B';
            else if (h < hh) c = 'P';
            else if (h < hm) c = 'H';
            else             c = 'M';
            outbuf[(size_t)xx * size + yy] = c;
        }
    }
    outbuf[(size_t)size * size] = '\0';
    return outbuf;
}
