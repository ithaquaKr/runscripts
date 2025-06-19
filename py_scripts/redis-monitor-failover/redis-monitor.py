#!/usr/bin/env python3
"""
Redis Sentinel Monitor Script (Python)
Continuously writes to Redis through Sentinel and monitors for downtime during failover
"""

import redis
import redis.sentinel
import time
import logging
import signal
import sys
import json

# Configuration
SENTINEL_HOSTS = [("172.30.0.1", 26380), ("172.30.0.1", 26381), ("172.30.0.1", 26382)]
MASTER_NAME = "mymaster"
TEST_KEY = "monitor:heartbeat"
WRITE_INTERVAL = 1  # seconds
LOG_FILE = "redis_monitor.log"
STATS_INTERVAL = 10  # Log stats every 20 operations


class RedisMonitor:
    def __init__(self):
        self.sentinel = None
        self.redis_client = None
        self.current_master = None
        self.consecutive_failures = 0
        self.start_time = time.time()
        self.total_operations = 0
        self.failed_operations = 0
        self.downtime_start = None
        self.total_downtime = 0
        self.running = True

        # Setup logging
        self.setup_logging()

        # Setup signal handlers
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)

    def setup_logging(self):
        """Configure logging to both file and console"""
        logging.basicConfig(
            level=logging.INFO,
            format="[%(asctime)s] [%(levelname)s] %(message)s",
            handlers=[logging.FileHandler(LOG_FILE), logging.StreamHandler(sys.stdout)],
        )
        self.logger = logging.getLogger(__name__)

    def signal_handler(self, signum, frame):
        """Handle shutdown signals gracefully"""
        self.logger.info(f"Received signal {signum}, shutting down...")
        self.running = False
        self.cleanup()
        sys.exit(0)

    def connect_to_sentinel(self) -> bool:
        """Connect to Redis Sentinel"""
        try:
            self.sentinel = redis.sentinel.Sentinel(
                SENTINEL_HOSTS, socket_timeout=2.0, socket_connect_timeout=2.0
            )
            self.logger.info("Connected to Redis Sentinel")
            return True
        except Exception as e:
            self.logger.error(f"Failed to connect to Sentinel: {e}")
            return False

    def get_master_connection(self) -> bool:
        """Get Redis master connection through Sentinel"""
        try:
            if not self.sentinel:
                if not self.connect_to_sentinel():
                    return False

            # Get master info
            master_info = self.sentinel.discover_master(MASTER_NAME)
            if not master_info:
                self.logger.error(f"Master '{MASTER_NAME}' not found")
                return False

            # Check if master changed
            if self.current_master and self.current_master != master_info:
                self.logger.info(
                    f"Master changed from {self.current_master} to {master_info}"
                )
                if self.downtime_start:
                    downtime = time.time() - self.downtime_start
                    self.total_downtime += downtime
                    self.logger.info(f"Downtime detected: {downtime:.2f} seconds")
                    self.downtime_start = None

            self.current_master = master_info

            # Get Redis connection
            self.redis_client = self.sentinel.master_for(
                MASTER_NAME,
                socket_timeout=2.0,
                socket_connect_timeout=2.0,
                retry_on_timeout=True,
            )

            # Test connection
            self.redis_client.ping()
            self.logger.info(
                f"Connected to Redis master: {master_info[0]}:{master_info[1]}"
            )
            return True

        except Exception as e:
            self.logger.error(f"Failed to get master connection: {e}")
            return False

    def write_test_data(self) -> tuple[bool, float]:
        """Write test data to Redis and measure latency"""
        if not self.redis_client:
            return False, 0

        timestamp = int(time.time())
        value = f"heartbeat_{timestamp}_{hash(time.time()) % 10000}"

        start_time = time.time()
        try:
            self.redis_client.set(TEST_KEY, value, ex=300)  # 5 minute expiry
            duration = (time.time() - start_time) * 1000  # Convert to ms
            self.total_operations += 1
            self.consecutive_failures = 0

            # Mark end of downtime if we were in downtime
            if self.downtime_start:
                downtime = time.time() - self.downtime_start
                self.total_downtime += downtime
                self.logger.info(
                    f"Service restored after {downtime:.2f} seconds of downtime"
                )
                self.downtime_start = None

            return True, duration

        except Exception as e:
            duration = (time.time() - start_time) * 1000
            self.total_operations += 1
            self.failed_operations += 1
            self.consecutive_failures += 1

            # Mark start of downtime
            if not self.downtime_start:
                self.downtime_start = time.time()
                self.logger.warning("Downtime started - Redis operations failing")

            self.logger.error(f"Failed to write to Redis: {e}")
            return False, duration

    def log_statistics(self):
        """Log current statistics"""
        uptime = time.time() - self.start_time
        success_rate = (
            (self.total_operations - self.failed_operations)
            / max(self.total_operations, 1)
        ) * 100

        # Calculate current downtime if in downtime state
        current_downtime = 0
        if self.downtime_start:
            current_downtime = time.time() - self.downtime_start

        total_downtime_display = self.total_downtime + current_downtime
        availability = (
            ((uptime - total_downtime_display) / uptime) * 100 if uptime > 0 else 100
        )

        stats = {
            "uptime_seconds": round(uptime, 2),
            "total_operations": self.total_operations,
            "failed_operations": self.failed_operations,
            "success_rate_percent": round(success_rate, 2),
            "total_downtime_seconds": round(total_downtime_display, 2),
            "availability_percent": round(availability, 4),
            "current_master": f"{self.current_master[0]}:{self.current_master[1]}"
            if self.current_master
            else "Unknown",
        }

        self.logger.info(f"STATS: {json.dumps(stats, indent=2)}")

    def monitor_loop(self):
        """Main monitoring loop"""
        self.logger.info("=== Starting Redis Sentinel Monitor ===")
        self.logger.info(f"Master name: {MASTER_NAME}")
        self.logger.info(f"Write interval: {WRITE_INTERVAL}s")
        self.logger.info(f"Sentinel hosts: {SENTINEL_HOSTS}")

        while self.running:
            try:
                # Connect if not connected or after consecutive failures
                if not self.redis_client or self.consecutive_failures >= 3:
                    if not self.get_master_connection():
                        self.logger.warning("Retrying connection in 5 seconds...")
                        time.sleep(5)
                        continue

                # Perform write operation
                success, duration = self.write_test_data()

                if success:
                    self.logger.debug(f"Write successful ({duration:.2f}ms)")
                else:
                    self.logger.warning(f"Write failed ({duration:.2f}ms)")

                # Log statistics periodically
                if self.total_operations % STATS_INTERVAL == 0:
                    self.log_statistics()

                time.sleep(WRITE_INTERVAL)

            except KeyboardInterrupt:
                break
            except Exception as e:
                self.logger.error(f"Unexpected error in monitor loop: {e}")
                time.sleep(5)

    def cleanup(self):
        """Cleanup resources"""
        self.logger.info("Performing cleanup...")
        self.log_statistics()

        if self.redis_client:
            self.redis_client.connection_pool.disconnect()

    def run(self):
        """Start the monitor"""
        try:
            self.monitor_loop()
        finally:
            self.cleanup()


# Additional utility functions for testing
def test_sentinel_connection():
    """Test function to verify Sentinel connectivity"""
    try:
        sentinel = redis.sentinel.Sentinel(SENTINEL_HOSTS)
        if sentinel.sentinel_masters():
            print("OK!")
    except Exception as e:
        print(f"Sentinel connection test failed: {e}")
        return


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Redis Sentinel Monitor")
    parser.add_argument(
        "--test-connection",
        action="store_true",
        help="Test Sentinel connection and exit",
    )

    args = parser.parse_args()

    if args.test_connection:
        test_sentinel_connection()
        sys.exit(0)

    # Run the monitor
    monitor = RedisMonitor()
    monitor.run()
