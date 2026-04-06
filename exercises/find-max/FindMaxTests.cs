using Xunit;

public class FindMaxTests
{
    [Fact]
    public void GetMax_ReturnsMaximumValue()
    {
        Assert.Equal(3, FindMax.GetMax(new[] { 1, 3, 2 }));
    }

    [Fact]
    public void GetMax_ReturnsMaximumForNegativeNumbers()
    {
        Assert.Equal(-1, FindMax.GetMax(new[] { -5, -1, -7 }));
    }

    [Fact]
    public void GetMax_ReturnsSingleElement()
    {
        Assert.Equal(42, FindMax.GetMax(new[] { 42 }));
    }

    [Fact]
    public void GetMax_ReturnsMaximum_WhenAllElementsEqual()
    {
        Assert.Equal(7, FindMax.GetMax(new[] { 7, 7, 7, 7 }));
    }

    [Fact]
    public void GetMax_WorksWithMixedNumbers()
    {
        Assert.Equal(5, FindMax.GetMax(new[] { -10, 0, 5, -3 }));
    }
}