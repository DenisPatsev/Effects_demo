using System;
using UnityEngine;

[Serializable]
public class PropertyBlockColor
{
    public string colorName;
    [ColorUsage(true, true)] public Color color;
}