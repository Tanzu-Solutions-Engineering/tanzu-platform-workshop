---
title: Scaling
---
29. Review spaces and scheduling to explain replicas and how they are different from individual deployment scale.
30. `tanzu app config scale set cpu=400 memory=678` for vertical scale.  `tanzu deploy --from-build /tmp/build` and `tanzu app get emoji-inclusion` to see change.
31. `tanzu app config scale set replicas=2` to scale horizontally in _each_ Kubernetes cluster the application is deployed to for an availability target.  `tanzu deploy --from-build /tmp/build` and `tanzu app get emoji-inclusion` to see change.
32. Explain Replicas for Availability Target (multiple clusters in one target)
33. Scaling across multiple ATs

