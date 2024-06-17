---
title: Scaling
---
29. Review spaces and scheduling to explain replicas and how they are different from individual deployment scale.
30. `tanzu app scale set cpu=400 memory=678` for vertical scale.  `tanzu deploy --from-build /tmp/build` and `tanzu app get emoji-inclusion` to see change.
31. `tanzu app scale set replicas=2` to scale horizontally in _each_ availability target.  `tanzu deploy --from-build /tmp/build` and `tanzu app get emoji-inclusion` to see change.
