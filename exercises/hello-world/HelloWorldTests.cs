using Xunit;

public class HelloWorldTests
{
    [Fact]
    public void SayHello_ReturnsHelloCodeLab()
    {
        Assert.Equal("Hello CodeLab!", HelloWorld.SayHello());
    }
}
