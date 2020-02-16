# Notes

These should find their way to the docs

## Type compatibility

Messages that Components can send to each other are typed. We assume that compatible types are loaded on both communicating ends. 

That means, backward compatibility of types should be maintained during the running phase of the
actor system, or inconsistencies must be managed on the application level.

> Plan: Circo itself will maintain backward compatibility within itself only between third number upgrades.
> The internal structure of every
> succesful business is chaotic during the first growing stages, but settles very quickly.
