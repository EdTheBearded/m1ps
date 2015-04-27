## (Very) Simple MIPS Processor ##
**Study of microarchitecture**

### Remarks ###
A simple processor as implemented on the digital circuit class.
It was provided as a single cycle processor, and I wanted to practice some topics viewed on Patterson - Hennessy book:
* Pipelining;
* Data forwarding.

## Implementation ##
On the pipelining topic, I have changed it's design so it would have a 5 stage pipeline an would resolve branches on the second stage.
And then I implemented a data forwarding unit, so I would minimise the number of inserted bubbles to the cases of load/use instruction sequence.